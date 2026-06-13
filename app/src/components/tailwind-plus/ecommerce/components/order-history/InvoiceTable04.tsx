// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const orders = [
  {
    number: 'WU88191111',
    date: 'January 22, 2021',
    datetime: '2021-01-22',
    invoiceHref: '#',
    total: '$238.00',
    products: [
      {
        id: 1,
        name: 'Machined Pen and Pencil Set',
        href: '#',
        price: '$70.00',
        status: 'Delivered Jan 25, 2021',
        imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/order-history-page-02-product-01.jpg',
        imageAlt: 'Detail of mechanical pencil tip with machined black steel shaft and chrome lead tip.',
      },
      {
        id: 2,
        name: 'Earthen Mug',
        href: '#',
        price: '$28.00',
        status: 'Delivered Jan 25, 2021',
        imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/order-history-page-02-product-02.jpg',
        imageAlt: 'Porcelain clay mug with squared handle, gray textured body, and natural clay rim and bottom.',
      },
      {
        id: 3,
        name: 'Leatherbound Daily Journal Set',
        href: '#',
        price: '$140.00',
        status: 'Delivered Jan 25, 2021',
        imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/order-history-page-02-product-03.jpg',
        imageAlt:
          'Natural leather cover journal with brass ring-3 binding, an embossed logo on bottom right of the cover, and 3 included paper refills.',
      },
    ],
  },
  {
    number: 'WU88191009',
    date: 'January 5, 2021',
    datetime: '2021-01-05',
    invoiceHref: '#',
    total: '$115.00',
    products: [
      {
        id: 1,
        name: 'Carry Clutch',
        href: '#',
        price: '$80.00',
        status: 'Delivered Jan 7, 2021',
        imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/order-history-page-02-product-04.jpg',
        imageAlt:
          'Folding zipper clutch with white fabric body, synthetic black leather accent strip, and black loop zipper pull.',
      },
      {
        id: 2,
        name: 'Nomad Tumbler',
        href: '#',
        price: '$35.00',
        status: 'Delivered Jan 7, 2021',
        imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/order-history-page-02-product-05.jpg',
        imageAlt: 'Black insulated bottle with flared screw lid and flat top.',
      },
    ],
  },
]

export function InvoiceTable04() {
  return (
    <div className="bg-white">
      <div className="mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8 lg:pb-24">
        <div className="max-w-xl">
          <h1 className="text-2xl font-bold tracking-tight text-gray-900 sm:text-3xl">Order history</h1>
          <p className="mt-2 text-sm text-gray-500">
            Check the status of recent orders, manage returns, and download invoices.
          </p>
        </div>

        <div className="mt-16">
          <h2 className="sr-only">Recent orders</h2>

          <div className="space-y-20">
            {orders.map((order) => (
              <div key={order.number}>
                <h3 className="sr-only">
                  Order placed on <time dateTime={order.datetime}>{order.date}</time>
                </h3>

                <div className="rounded-lg bg-gray-50 px-4 py-6 sm:flex sm:items-center sm:justify-between sm:space-x-6 sm:px-6 lg:space-x-8">
                  <dl className="flex-auto divide-y divide-gray-200 text-sm text-gray-600 sm:grid sm:grid-cols-3 sm:gap-x-6 sm:divide-y-0 lg:w-1/2 lg:flex-none lg:gap-x-8">
                    <div className="max-sm:flex max-sm:justify-between max-sm:py-6 max-sm:first:pt-0 max-sm:last:pb-0">
                      <dt className="font-medium text-gray-900">Date placed</dt>
                      <dd className="sm:mt-1">
                        <time dateTime={order.datetime}>{order.date}</time>
                      </dd>
                    </div>
                    <div className="max-sm:flex max-sm:justify-between max-sm:py-6 max-sm:first:pt-0 max-sm:last:pb-0">
                      <dt className="font-medium text-gray-900">Order number</dt>
                      <dd className="sm:mt-1">{order.number}</dd>
                    </div>
                    <div className="max-sm:flex max-sm:justify-between max-sm:py-6 max-sm:first:pt-0 max-sm:last:pb-0">
                      <dt className="font-medium text-gray-900">Total amount</dt>
                      <dd className="font-medium text-gray-900 sm:mt-1">{order.total}</dd>
                    </div>
                  </dl>
                  <a
                    href={order.invoiceHref}
                    className="mt-6 flex w-full items-center justify-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 shadow-xs hover:bg-gray-50 focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:outline-hidden sm:mt-0 sm:w-auto"
                  >
                    View Invoice
                    <span className="sr-only">for order {order.number}</span>
                  </a>
                </div>

                <table className="mt-4 w-full text-gray-500 sm:mt-6">
                  <caption className="sr-only">Products</caption>
                  <thead className="sr-only text-left text-sm text-gray-500 sm:not-sr-only">
                    <tr>
                      <th scope="col" className="py-3 pr-8 font-normal sm:w-2/5 lg:w-1/3">
                        Product
                      </th>
                      <th scope="col" className="hidden w-1/5 py-3 pr-8 font-normal sm:table-cell">
                        Price
                      </th>
                      <th scope="col" className="hidden py-3 pr-8 font-normal sm:table-cell">
                        Status
                      </th>
                      <th scope="col" className="w-0 py-3 text-right font-normal">
                        Info
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200 border-b border-gray-200 text-sm sm:border-t">
                    {order.products.map((product) => (
                      <tr key={product.id}>
                        <td className="py-6 pr-8">
                          <div className="flex items-center">
                            <img
                              alt={product.imageAlt}
                              src={product.imageSrc}
                              className="mr-6 size-16 rounded-sm object-cover"
                            />
                            <div>
                              <div className="font-medium text-gray-900">{product.name}</div>
                              <div className="mt-1 sm:hidden">{product.price}</div>
                            </div>
                          </div>
                        </td>
                        <td className="hidden py-6 pr-8 sm:table-cell">{product.price}</td>
                        <td className="hidden py-6 pr-8 sm:table-cell">{product.status}</td>
                        <td className="py-6 text-right font-medium whitespace-nowrap">
                          <a href={product.href} className="text-indigo-600">
                            View<span className="hidden lg:inline"> Product</span>
                            <span className="sr-only">, {product.name}</span>
                          </a>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
