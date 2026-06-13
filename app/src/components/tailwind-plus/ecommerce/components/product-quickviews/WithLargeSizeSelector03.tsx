// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck

'use client'

import { useState } from 'react'
import { Dialog, DialogBackdrop, DialogPanel } from '@headlessui/react'
import { ShieldCheckIcon, XMarkIcon } from '@heroicons/react/24/outline'
import { CheckCircleIcon, CheckIcon, QuestionMarkCircleIcon, StarIcon } from '@heroicons/react/20/solid'

const product = {
  name: 'Everyday Ruck Snack',
  price: '$220',
  rating: 3.9,
  href: '#',
  imageSrc: 'https://tailwindcss.com/plus-assets/img/ecommerce-images/product-quick-preview-03-detail.jpg',
  imageAlt: 'Interior of light green canvas bag with padded laptop sleeve and internal organization pouch.',
  sizes: [
    { name: '18L', description: 'Perfect for a reasonable amount of snacks.' },
    { name: '20L', description: 'Enough room for a large amount of snacks.' },
  ],
}

function classNames(...classes) {
  return classes.filter(Boolean).join(' ')
}

export function WithLargeSizeSelector03() {
  const [open, setOpen] = useState(false)

  return (
    <Dialog open={open} onClose={setOpen} className="relative z-10">
      <DialogBackdrop
        transition
        className="fixed inset-0 hidden bg-gray-500/75 transition-opacity data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in md:block"
      />

      <div className="fixed inset-0 z-10 w-screen overflow-y-auto">
        <div className="flex min-h-full items-stretch justify-center text-center md:items-center md:px-2 lg:px-4">
          <DialogPanel
            transition
            className="flex w-full transform text-left text-base transition data-closed:translate-y-4 data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in md:my-8 md:max-w-2xl md:px-4 data-closed:md:translate-y-0 data-closed:md:scale-95 lg:max-w-4xl"
          >
            <div className="relative flex w-full items-center overflow-hidden bg-white px-4 pt-14 pb-8 shadow-2xl sm:px-6 sm:pt-8 md:p-6 lg:p-8">
              <button
                type="button"
                onClick={() => setOpen(false)}
                className="absolute top-4 right-4 text-gray-400 hover:text-gray-500 sm:top-8 sm:right-6 md:top-6 md:right-6 lg:top-8 lg:right-8"
              >
                <span className="sr-only">Close</span>
                <XMarkIcon aria-hidden="true" className="size-6" />
              </button>

              <div className="grid w-full grid-cols-1 items-start gap-x-6 gap-y-8 sm:grid-cols-12 lg:gap-x-8">
                <div className="sm:col-span-4 lg:col-span-5">
                  <img
                    alt={product.imageAlt}
                    src={product.imageSrc}
                    className="aspect-square w-full rounded-lg bg-gray-100 object-cover"
                  />
                  <p className="absolute top-4 left-4 text-center sm:static sm:mt-6">
                    <a href={product.href} className="font-medium text-indigo-600 hover:text-indigo-500">
                      View full details
                    </a>
                  </p>
                </div>
                <div className="sm:col-span-8 lg:col-span-7">
                  <h2 className="text-2xl font-bold text-gray-900 sm:pr-12">{product.name}</h2>

                  <section aria-labelledby="information-heading" className="mt-4">
                    <h3 id="information-heading" className="sr-only">
                      Product information
                    </h3>

                    <div className="flex items-center">
                      <p className="text-lg text-gray-900 sm:text-xl">{product.price}</p>

                      <div className="ml-4 border-l border-gray-300 pl-4">
                        <h4 className="sr-only">Reviews</h4>
                        <div className="flex items-center">
                          <div className="flex items-center">
                            {[0, 1, 2, 3, 4].map((rating) => (
                              <StarIcon
                                key={rating}
                                aria-hidden="true"
                                className={classNames(
                                  product.rating > rating ? 'text-yellow-400' : 'text-gray-300',
                                  'size-5 shrink-0',
                                )}
                              />
                            ))}
                          </div>
                          <p className="sr-only">{product.rating} out of 5 stars</p>
                        </div>
                      </div>
                    </div>

                    <div className="mt-6 flex items-center">
                      <CheckIcon aria-hidden="true" className="size-5 shrink-0 text-green-500" />
                      <p className="ml-2 font-medium text-gray-500">In stock and ready to ship</p>
                    </div>
                  </section>

                  <section aria-labelledby="options-heading" className="mt-6">
                    <h3 id="options-heading" className="sr-only">
                      Product options
                    </h3>

                    <form>
                      <div className="sm:flex sm:justify-between">
                        {/* Size selector */}
                        <fieldset>
                          <legend className="block text-sm font-medium text-gray-700">Size</legend>
                          <div className="mt-1 grid grid-cols-1 gap-4 sm:grid-cols-2">
                            {product.sizes.map((size) => (
                              <label
                                key={size.name}
                                aria-label={size.name}
                                aria-description={size.description}
                                className="group relative flex rounded-lg border border-gray-300 bg-white p-4 has-checked:outline-2 has-checked:-outline-offset-2 has-checked:outline-indigo-600 has-focus-visible:outline-3 has-focus-visible:-outline-offset-1 has-disabled:border-gray-400 has-disabled:bg-gray-200 has-disabled:opacity-25"
                              >
                                <input
                                  defaultValue={size.name}
                                  defaultChecked={size === product.sizes[0]}
                                  name="size"
                                  type="radio"
                                  className="absolute inset-0 appearance-none focus:outline-none"
                                />
                                <div className="flex-1">
                                  <span className="block text-base font-medium text-gray-900">{size.name}</span>
                                  <span className="mt-1 block text-sm text-gray-500">{size.description}</span>
                                </div>
                                <CheckCircleIcon
                                  aria-hidden="true"
                                  className="invisible size-5 text-indigo-600 group-has-checked:visible"
                                />
                              </label>
                            ))}
                          </div>
                        </fieldset>
                      </div>
                      <div className="mt-4 flex">
                        <a href="#" className="group flex text-sm text-gray-500 hover:text-gray-700">
                          <span>What size should I buy?</span>
                          <QuestionMarkCircleIcon
                            aria-hidden="true"
                            className="ml-2 size-5 shrink-0 text-gray-400 group-hover:text-gray-500"
                          />
                        </a>
                      </div>
                      <div className="mt-6">
                        <button
                          type="submit"
                          className="flex w-full items-center justify-center rounded-md border border-transparent bg-indigo-600 px-8 py-3 text-base font-medium text-white hover:bg-indigo-700 focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-50 focus:outline-hidden"
                        >
                          Add to bag
                        </button>
                      </div>
                      <div className="mt-6 text-center">
                        <a href="#" className="group inline-flex text-base font-medium">
                          <ShieldCheckIcon
                            aria-hidden="true"
                            className="mr-2 size-6 shrink-0 text-gray-400 group-hover:text-gray-500"
                          />
                          <span className="text-gray-500 group-hover:text-gray-700">Lifetime Guarantee</span>
                        </a>
                      </div>
                    </form>
                  </section>
                </div>
              </div>
            </div>
          </DialogPanel>
        </div>
      </div>
    </Dialog>
  )
}
