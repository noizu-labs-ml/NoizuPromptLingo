// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const products = [
  {
    id: 1,
    name: 'Nomad Pouch',
    href: '#',
    price: '$50',
    availability: 'White and Black',
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-07-product-01.jpg',
    imageAlt: 'White fabric pouch with white zipper, black zipper pull, and black elastic loop.',
  },
  {
    id: 2,
    name: 'Zip Tote Basket',
    href: '#',
    price: '$140',
    availability: 'Washed Black',
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-07-product-02.jpg',
    imageAlt: 'Front of tote bag with washed black canvas body, black straps, and tan leather handles and accents.',
  },
  {
    id: 3,
    name: 'Medium Stuff Satchel',
    href: '#',
    price: '$220',
    availability: 'Blue',
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-07-product-03.jpg',
    imageAlt:
      'Front of satchel with blue canvas body, black straps and handle, drawstring top, and front zipper pouch.',
  },
  {
    id: 4,
    name: 'High Wall Tote',
    href: '#',
    price: '$210',
    availability: 'Black and Orange',
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-07-product-04.jpg',
    imageAlt: 'Front of zip tote bag with black canvas, black handles, and orange drawstring top.',
  },
  {
    id: 5,
    name: 'Zip Tote Basket',
    href: '#',
    price: '$140',
    availability: 'White and black',
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-07-product-05.jpg',
    imageAlt: 'Front of zip tote bag with white canvas, black canvas straps and handle, and black zipper pulls.',
  },
  {
    id: 6,
    name: 'Zip High Wall Tote',
    href: '#',
    price: '$150',
    availability: 'White and blue',
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-07-product-06.jpg',
    imageAlt: 'Front of zip tote bag with white canvas, blue canvas straps and handle, and front zipper pocket.',
  },
]

export function WithSupportingText09() {
  return (
    <div className="bg-white">
      <div className="mx-auto max-w-7xl overflow-hidden px-4 py-16 sm:px-6 sm:py-24 lg:px-8">
        <div className="grid grid-cols-1 gap-x-6 gap-y-10 sm:grid-cols-2 lg:grid-cols-3 lg:gap-x-8">
          {products.map((product) => (
            <a key={product.id} href={product.href} className="group text-sm">
              <img
                alt={product.imageAlt}
                src={product.imageSrc}
                className="aspect-square w-full rounded-lg bg-gray-100 object-cover group-hover:opacity-75"
              />
              <h3 className="mt-4 font-medium text-gray-900">{product.name}</h3>
              <p className="text-gray-500 italic">{product.availability}</p>
              <p className="mt-2 font-medium text-gray-900">{product.price}</p>
            </a>
          ))}
        </div>
      </div>
    </div>
  )
}
