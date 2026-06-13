// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function SimpleLeftAligned05() {
  return (
    <div className="bg-white py-24 sm:py-32 dark:bg-gray-900">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mx-auto max-w-2xl lg:max-w-none">
          <h2 className="text-lg/8 font-semibold text-gray-900 dark:text-white">
            Trusted by the world’s most innovative teams
          </h2>
          <div className="mx-auto mt-10 grid grid-cols-4 items-start gap-x-8 gap-y-10 sm:grid-cols-6 sm:gap-x-10 lg:mx-0 lg:grid-cols-5">
            <img
              alt="Transistor"
              src="https://tailwindcss.com/plus-assets/img/logos/transistor-logo-gray-900.svg"
              width={158}
              height={48}
              className="col-span-2 max-h-12 w-full object-contain object-left lg:col-span-1 dark:hidden"
            />
            <img
              alt="Transistor"
              src="https://tailwindcss.com/plus-assets/img/logos/transistor-logo-white.svg"
              width={158}
              height={48}
              className="col-span-2 max-h-12 w-full object-contain object-left not-dark:hidden lg:col-span-1"
            />

            <img
              alt="Reform"
              src="https://tailwindcss.com/plus-assets/img/logos/reform-logo-gray-900.svg"
              width={158}
              height={48}
              className="col-span-2 max-h-12 w-full object-contain object-left lg:col-span-1 dark:hidden"
            />
            <img
              alt="Reform"
              src="https://tailwindcss.com/plus-assets/img/logos/reform-logo-white.svg"
              width={158}
              height={48}
              className="col-span-2 max-h-12 w-full object-contain object-left not-dark:hidden lg:col-span-1"
            />

            <img
              alt="Tuple"
              src="https://tailwindcss.com/plus-assets/img/logos/tuple-logo-gray-900.svg"
              width={158}
              height={48}
              className="col-span-2 max-h-12 w-full object-contain object-left lg:col-span-1 dark:hidden"
            />
            <img
              alt="Tuple"
              src="https://tailwindcss.com/plus-assets/img/logos/tuple-logo-white.svg"
              width={158}
              height={48}
              className="col-span-2 max-h-12 w-full object-contain object-left not-dark:hidden lg:col-span-1"
            />

            <img
              alt="SavvyCal"
              src="https://tailwindcss.com/plus-assets/img/logos/savvycal-logo-gray-900.svg"
              width={158}
              height={48}
              className="col-span-2 max-h-12 w-full object-contain object-left lg:col-span-1 dark:hidden"
            />
            <img
              alt="SavvyCal"
              src="https://tailwindcss.com/plus-assets/img/logos/savvycal-logo-white.svg"
              width={158}
              height={48}
              className="col-span-2 max-h-12 w-full object-contain object-left not-dark:hidden lg:col-span-1"
            />

            <img
              alt="Statamic"
              src="https://tailwindcss.com/plus-assets/img/logos/statamic-logo-gray-900.svg"
              width={158}
              height={48}
              className="col-span-2 max-h-12 w-full object-contain object-left lg:col-span-1 dark:hidden"
            />
            <img
              alt="Statamic"
              src="https://tailwindcss.com/plus-assets/img/logos/statamic-logo-white.svg"
              width={158}
              height={48}
              className="col-span-2 max-h-12 w-full object-contain object-left not-dark:hidden lg:col-span-1"
            />
          </div>
        </div>
      </div>
    </div>
  )
}
