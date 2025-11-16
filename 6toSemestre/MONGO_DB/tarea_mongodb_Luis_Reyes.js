//A) Fundamentos----------------

//Q1. Listar productos de la categoría “Electrónica” con price entre 200 y 1200 (incluidos). Requisitos: proyectar name, brand, price; ordenar por price descendente.
db.products.find({
  category: "Electrónica",
  price: { $gte: 200, $lte:1200 }
},{
  name:1, brand:1, price: 1, _id:0
})

//Q2. Listar órdenes de los últimos 30 días con status en paid o delivered y total ≥ 1000. Requisitos: devolver _id, customerId, total, status, createdAt.
var ultimosTreintaDias = 30*24*60*60*1000;
db.orders.find({
  createdAt: {
    $gte: new Date(Date.now()-ultimosTreintaDias)
  },
  status: { $in: ["paid", "delivered"]},
  total: { $gte: 1000 }
},{
  _id:1, customerId:1, total:1, status:1, createdAt:1
})

//Q3. Listar órdenes que contengan un productId dado con qty ≥ 3 dentro de items. Requisitos: usa un filtro sobre el array ($elemMatch); devolver _id y un subconjunto de items que evidencie el match.
db.orders.find({
  items: {
    $elemMatch: {
      productId: ObjectId("690f53aa0cf906e26b63c58b"),
      qty: { $gte: 3}
    }
  }
},{
  _id:1,
  items: {
    $filter: {
      input: "$items",
      as: "item",
      cond: {
        $and: [
          { $eq: ["$$item.productId", ObjectId("690f53aa0cf906e26b63c58b")] },
          { $gte: ["$$item.qty", 3] }
        ]
      }
    }
  }
})

//Q4. Listar productos cuyas tallas (attrs.sizes) incluyan simultáneamente M y L. Requisitos: proyectar name y attrs.sizes.
db.products.find({
  "attrs.sizes": { $all: ["M","L"]}
},{
  name: 1, "attrs.sizes":1, _id:0
})

//Q5. Listar clientes de “Guatemala City” con phones existente y de tipo array, que no tengan la etiqueta vip. Requisitos: proyectar name, email, phones.
db.customers.find(
  {
    "address.city": "Guatemala City",
    phones: { $exists: true, $type: "array" },
    tags: { $ne: "vip" }
  },
  {
    _id: 0,
    name: 1,
    email: 1,
    phones: 1
  }
)

//B) Agregación-----------------

//Q6. Calcular el AOV global (Average Order Value) sobre órdenes con status en paid/shipped/delivered. Requisitos: devolver número de órdenes y AOV redondeado a 2 decimales.
db.orders.aggregate([
  {
    $match: {
      status: { $in: ["paid", "shipped", "delivered"] }
    }
  },
  {
    $group: {
      _id: null,
      orderCount: { $sum: 1 },
      avgTotal: { $avg: "$total" }
    }
  },
  {
    $project: {
      _id: 0,
      orderCount: 1,
      AOV: { $round: ["$avgTotal", 2] }
    }
  }
])


//Q7. Calcular el AOV por ciudad usando shippingAddressSnapshot.city. Requisitos: devolver city, orders, aov; ordenar por aov descendente.
db.orders.aggregate([
  {
    $group: {
      _id: "$shippingAddressSnapshot.city",
      orders: { $sum: 1 },
      avgTotal: { $avg: "$total" }
    }
  },
  {
    $project: {
      _id: 0,
      city: "$_id",
      orders: 1,
      aov: { $round: ["$avgTotal", 2] }
    }
  },
  {
    $sort: { aov: -1 }
  }
])


//Q8. Obtener el Top 10 productos por ingreso en los últimos 30 días. Requisitos: devolver productId, name, category, revenue, units; ordenar por revenue descendente. Debes enriquecer con products (join con $lookup).
db.orders.aggregate([
  // 1. Filtrar órdenes de los últimos 30 días
  {
    $match: {
      createdAt: {
        $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
      }
    }
  },

  // 2. Desnormalizar items
  { $unwind: "$items" },

  // 3. Agrupar por productId
  {
    $group: {
      _id: "$items.productId",
      units: { $sum: "$items.qty" },
      revenue: { $sum: { $multiply: ["$items.qty", "$items.price"] } }
    }
  },

  // 4. Enriquecer con products (join)
  {
    $lookup: {
      from: "products",
      localField: "_id",
      foreignField: "_id",
      as: "product"
    }
  },

  // 5. Flatten del array "product"
  { $unwind: "$product" },

  // 6. Proyección final
  {
    $project: {
      _id: 0,
      productId: "$_id",
      name: "$product.name",
      category: "$product.category",
      units: 1,
      revenue: 1
    }
  },

  // 7. Ordenar por revenue desc
  { $sort: { revenue: -1 } },

  // 8. Top 10
  { $limit: 10 }
])


//Q9. Calcular la recurrencia de clientes: proporción de clientes con ≥ 2 órdenes sobre los que tienen ≥ 1. Requisitos: devolver una métrica repeatRate con 4 decimales.
db.orders.aggregate([
  // 1. Agrupar por cliente y contar cuántas órdenes tiene
  {
    $group: {
      _id: "$customerId",
      orders: { $sum: 1 }
    }
  },

  // 2. Clasificar clientes según su número de órdenes
  {
    $group: {
      _id: null,
      customersWithOneOrMore: { 
        $sum: { $cond: [{ $gte: ["$orders", 1] }, 1, 0] }
      },
      customersWithTwoOrMore: { 
        $sum: { $cond: [{ $gte: ["$orders", 2] }, 1, 0] }
      }
    }
  },

  // 3. Calcular la tasa de recurrencia
  {
    $project: {
      _id: 0,
      repeatRate: {
        $round: [
          {
            $divide: [
              "$customersWithTwoOrMore",
              "$customersWithOneOrMore"
            ]
          },
          4
        ]
      }
    }
  }
])

//Q10. Construir una búsqueda con facetas en products para price en [200, 1200]. Requisitos: results: top 20 por price desc con name, brand, category, price; byCategory: conteo por categoría; priceBands: buckets de precio con límites [0,200,500,1000,1500,5000] y un default para >1500.
db.products.aggregate([
  // 1. Filtro base
  {
    $match: {
      price: { $gte: 200, $lte: 1200 }
    }
  },

  // 2. Facetas
  {
    $facet: {
      // A) Resultados principales
      results: [
        { $sort: { price: -1 } },
        { $limit: 20 },
        {
          $project: {
            _id: 0,
            name: 1,
            brand: 1,
            category: 1,
            price: 1
          }
        }
      ],

      // B) Conteo por categoría
      byCategory: [
        {
          $group: {
            _id: "$category",
            count: { $sum: 1 }
          }
        },
        {
          $project: {
            _id: 0,
            category: "$_id",
            count: 1
          }
        },
        { $sort: { count: -1 } }
      ],

      // C) Buckets de precio
      priceBands: [
        {
          $bucket: {
            groupBy: "$price",
            boundaries: [0, 200, 500, 1000, 1500, 5000],
            default: ">1500",
            output: { count: { $sum: 1 } }
          }
        }
      ]
    }
  }
])
