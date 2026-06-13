// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const orders = [
  {
    number: '4376',
    status: 'Delivered on January 22, 2021',
    href: '#',
    invoiceHref: '#',
    products: [
      {
        id: 1,
        name: 'Machined Brass Puzzle',
        href: '#',
        price: '$95.00',
        color: 'Brass',
        size: '3" x 3" x 3"',
        imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/order-history-page-07-product-01.jpg',
        imageAlt: 'Brass puzzle in the shape of a jack with overlapping rounded posts.',
      },
      {
        id: 2,
        name: 'Earthen Planter',
        href: '#',
        price: '$62.00',
        color: 'Natural',
        size: 'Large',
        imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/order-history-page-07-product-02.jpg',
        imageAlt: 'Large cylindrical planter with textured natural porcelain color and separate drainage base.',
      },
      {
        id: 3,
        name: 'Minimalist Leather Wallet',
        href: '#',
        price: '$640.00',
        color: 'Olive',
        size: '4" L x 2.75" W',
        imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/order-history-page-07-product-03.jpg',
        imageAlt: 'Olive green leather card-sized wallet with matching hand stitched and embossed logo on lower right.',
      },
    ],
  },
  {
    number: '4134',
    status: 'Delivered on January 5, 2021',
    href: '#',
    invoiceHref: '#',
    products: [
      {
        id: 1,
        name: 'Machined Steel Bookends',
        href: '#',
        price: '$95.00',
        color: 'Black',
        size: '7.75" H x 6" W x 4.5" D',
        imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/order-history-page-07-product-04.jpg',
        imageAlt: 'Black powder coated steel bookends with bent rod l-shape.',
      },
    ],
  },
]

export function InvoiceListWithQuickActions07() {
  return (
    <div className="bg-white">
      <div className="mx-auto max-w-3xl px-4 py-16 sm:px-6 sm:py-24">
        <div className="max-w-xl">
          <h1 id="your-orders-heading" className="text-3xl font-bold tracking-tight text-gray-900">
            Your Orders
          </h1>
          <p className="mt-2 text-sm text-gray-500">
            Check the status of recent orders, manage returns, and discover similar products.
          </p>
        </div>

        <div className="mt-12 space-y-16 sm:mt-16">
          {orders.map((order) => (
            <section key={order.number} aria-labelledby={`${order.number}-heading`}>
              <div className="space-y-1 md:flex md:items-baseline md:space-y-0 md:space-x-4">
                <h2 id={`${order.number}-heading`} className="text-lg font-medium text-gray-900 md:shrink-0">
                  Order #{order.number}
                </h2>
                <div className="space-y-5 sm:flex sm:items-baseline sm:justify-between sm:space-y-0 md:min-w-0 md:flex-1">
                  <p className="text-sm font-medium text-gray-500">{order.status}</p>
                  <div className="flex text-sm font-medium">
                    <a href={order.href} className="text-indigo-600 hover:text-indigo-500">
                      Manage order
                    </a>
                    <div className="ml-4 border-l border-gray-200 pl-4 sm:ml-6 sm:pl-6">
                      <a href={order.invoiceHref} className="text-indigo-600 hover:text-indigo-500">
                        View Invoice
                      </a>
                    </div>
                  </div>
                </div>
              </div>

              <div className="mt-6 -mb-6 flow-root divide-y divide-gray-200 border-t border-gray-200">
                {order.products.map((product) => (
                  <div key={product.id} className="py-6 sm:flex">
                    <div className="flex space-x-4 sm:min-w-0 sm:flex-1 sm:space-x-6 lg:space-x-8">
                      <img
                        alt={product.imageAlt}
                        src={product.imageSrc}
                        className="size-20 flex-none rounded-md object-cover sm:size-48"
                      />
                      <div className="min-w-0 flex-1 pt-1.5 sm:pt-0">
                        <h3 className="text-sm font-medium text-gray-900">
                          <a href={product.href}>{product.name}</a>
                        </h3>
                        <p className="truncate text-sm text-gray-500">
                          <span>{product.color}</span>{' '}
                          <span aria-hidden="true" className="mx-1 text-gray-400">
                            &middot;
                          </span>{' '}
                          <span>{product.size}</span>
                        </p>
                        <p className="mt-1 font-medium text-gray-900">{product.price}</p>
                      </div>
                    </div>
                    <div className="mt-6 space-y-4 sm:mt-0 sm:ml-6 sm:w-40 sm:flex-none">
                      <button
                        type="button"
                        className="flex w-full items-center justify-center rounded-md border border-transparent bg-indigo-600 px-2.5 py-2 text-sm font-medium text-white shadow-xs hover:bg-indigo-700 focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:outline-hidden sm:grow-0"
                      >
                        Buy again
                      </button>
                      <button
                        type="button"
                        className="flex w-full items-center justify-center rounded-md border border-gray-300 bg-white px-2.5 py-2 text-sm font-medium text-gray-700 shadow-xs hover:bg-gray-50 focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:outline-hidden sm:grow-0"
                      >
                        Shop similar
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </section>
          ))}
        </div>
      </div>
    </div>
  )
}
