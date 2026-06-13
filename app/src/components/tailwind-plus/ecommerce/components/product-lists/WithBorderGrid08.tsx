// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { StarIcon } from '@heroicons/react/20/solid'

const products = [
  {
    id: 1,
    name: 'Organize Basic Set (Walnut)',
    price: '$149',
    rating: 5,
    reviewCount: 38,
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-05-image-card-01.jpg',
    imageAlt: 'TODO',
    href: '#',
  },
  {
    id: 2,
    name: 'Organize Pen Holder',
    price: '$15',
    rating: 5,
    reviewCount: 18,
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-05-image-card-02.jpg',
    imageAlt: 'TODO',
    href: '#',
  },
  {
    id: 3,
    name: 'Organize Sticky Note Holder',
    price: '$15',
    rating: 5,
    reviewCount: 14,
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-05-image-card-03.jpg',
    imageAlt: 'TODO',
    href: '#',
  },
  {
    id: 4,
    name: 'Organize Phone Holder',
    price: '$15',
    rating: 4,
    reviewCount: 21,
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-05-image-card-04.jpg',
    imageAlt: 'TODO',
    href: '#',
  },
  {
    id: 5,
    name: 'Organize Small Tray',
    price: '$15',
    rating: 4,
    reviewCount: 22,
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-05-image-card-05.jpg',
    imageAlt: 'TODO',
    href: '#',
  },
  {
    id: 6,
    name: 'Organize Basic Set (Maple)',
    price: '$149',
    rating: 5,
    reviewCount: 64,
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-05-image-card-06.jpg',
    imageAlt: 'TODO',
    href: '#',
  },
  {
    id: 7,
    name: 'Out and About Bottle',
    price: '$25',
    rating: 4,
    reviewCount: 12,
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-05-image-card-07.jpg',
    imageAlt: 'TODO',
    href: '#',
  },
  {
    id: 8,
    name: 'Daily Notebook Refill Pack',
    price: '$14',
    rating: 4,
    reviewCount: 41,
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-05-image-card-08.jpg',
    imageAlt: 'TODO',
    href: '#',
  },
  {
    id: 9,
    name: 'Leather Key Ring (Black)',
    price: '$32',
    rating: 5,
    reviewCount: 24,
    imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/category-page-05-image-card-09.jpg',
    imageAlt: 'TODO',
    href: '#',
  },
]

function classNames(...classes) {
  return classes.filter(Boolean).join(' ')
}

export function WithBorderGrid08() {
  return (
    <div className="bg-white">
      <div className="mx-auto max-w-7xl overflow-hidden sm:px-6 lg:px-8">
        <h2 className="sr-only">Products</h2>

        <div className="-mx-px grid grid-cols-2 border-l border-gray-200 sm:mx-0 md:grid-cols-3 lg:grid-cols-4">
          {products.map((product) => (
            <div key={product.id} className="group relative border-r border-b border-gray-200 p-4 sm:p-6">
              <img
                alt={product.imageAlt}
                src={product.imageSrc}
                className="aspect-square rounded-lg bg-gray-200 object-cover group-hover:opacity-75"
              />
              <div className="pt-10 pb-4 text-center">
                <h3 className="text-sm font-medium text-gray-900">
                  <a href={product.href}>
                    <span aria-hidden="true" className="absolute inset-0" />
                    {product.name}
                  </a>
                </h3>
                <div className="mt-3 flex flex-col items-center">
                  <p className="sr-only">{product.rating} out of 5 stars</p>
                  <div className="flex items-center">
                    {[0, 1, 2, 3, 4].map((rating) => (
                      <StarIcon
                        key={rating}
                        aria-hidden="true"
                        className={classNames(
                          product.rating > rating ? 'text-yellow-400' : 'text-gray-200',
                          'size-5 shrink-0',
                        )}
                      />
                    ))}
                  </div>
                  <p className="mt-1 text-sm text-gray-500">{product.reviewCount} reviews</p>
                </div>
                <p className="mt-4 text-base font-medium text-gray-900">{product.price}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
