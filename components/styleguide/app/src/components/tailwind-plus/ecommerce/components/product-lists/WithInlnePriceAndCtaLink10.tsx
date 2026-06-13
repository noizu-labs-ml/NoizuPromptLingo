// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const products = [
  {
    id: 1,
    name: 'Fusion',
    category: 'UI Kit',
    href: '#',
    price: '$49',
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/product-page-05-related-product-01.jpg',
    imageAlt:
      'Payment application dashboard screenshot with transaction table, financial highlights, and main clients on colorful purple background.',
  },
  {
    id: 2,
    name: 'Marketing Icon Pack',
    category: 'Icons',
    href: '#',
    price: '$19',
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/product-page-05-related-product-02.jpg',
    imageAlt: 'Calendar user interface screenshot with icon buttons and orange-yellow theme.',
  },
  {
    id: 3,
    name: 'Scaffold',
    category: 'Wireframe Kit',
    href: '#',
    price: '$29',
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/product-page-05-related-product-03.jpg',
    imageAlt:
      'Pricing page screenshot with tiered plan options and comparison table on colorful blue and green background.',
  },
  {
    id: 4,
    name: 'Bones',
    category: 'Wireframe Kit',
    href: '#',
    price: '$29',
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/product-page-05-related-product-04.jpg',
    imageAlt:
      'Application screenshot with tiered navigation and account settings form on color red and purple background.',
  },
]

export function WithInlnePriceAndCtaLink10() {
  return (
    <div className="bg-white">
      <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
        <div className="flex items-center justify-between space-x-4">
          <h2 className="text-lg font-medium text-gray-900">Customers also viewed</h2>
          <a href="#" className="text-sm font-medium whitespace-nowrap text-indigo-600 hover:text-indigo-500">
            View all
            <span aria-hidden="true"> &rarr;</span>
          </a>
        </div>
        <div className="mt-6 grid grid-cols-1 gap-x-8 gap-y-8 sm:grid-cols-2 sm:gap-y-10 lg:grid-cols-4">
          {products.map((product) => (
            <div key={product.id} className="group relative">
              <div className="relative">
                <img
                  alt={product.imageAlt}
                  src={product.imageSrc}
                  className="aspect-4/3 w-full rounded-lg bg-gray-100 object-cover"
                />
                <div
                  aria-hidden="true"
                  className="absolute inset-0 flex items-end p-4 opacity-0 group-hover:opacity-100"
                >
                  <div className="w-full rounded-md bg-white/75 px-4 py-2 text-center text-sm font-medium text-gray-900 backdrop-blur-sm backdrop-filter">
                    View Product
                  </div>
                </div>
              </div>
              <div className="mt-4 flex items-center justify-between space-x-8 text-base font-medium text-gray-900">
                <h3>
                  <a href="#">
                    <span aria-hidden="true" className="absolute inset-0" />
                    {product.name}
                  </a>
                </h3>
                <p>{product.price}</p>
              </div>
              <p className="mt-1 text-sm text-gray-500">{product.category}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
