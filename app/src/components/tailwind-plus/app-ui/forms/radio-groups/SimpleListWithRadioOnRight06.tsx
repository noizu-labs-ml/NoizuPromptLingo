// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const sides = [
  { id: null, name: 'None' },
  { id: 1, name: 'Baked beans' },
  { id: 2, name: 'Coleslaw' },
  { id: 3, name: 'French fries' },
  { id: 4, name: 'Garden salad' },
  { id: 5, name: 'Mashed potatoes' },
]

export function SimpleListWithRadioOnRight06() {
  return (
    <fieldset>
      <legend className="text-sm/6 font-semibold text-gray-900 dark:text-white">Select a side</legend>
      <div className="mt-4 divide-y divide-gray-200 border-t border-b border-gray-200 dark:divide-white/10 dark:border-white/10">
        {sides.map((side, sideIdx) => (
          <div key={sideIdx} className="relative flex items-start py-4">
            <div className="min-w-0 flex-1 text-sm/6">
              <label htmlFor={`side-${side.id}`} className="font-medium text-gray-900 select-none dark:text-white">
                {side.name}
              </label>
            </div>
            <div className="ml-3 flex h-6 items-center">
              <input
                defaultChecked={side.id === null}
                id={`side-${side.id}`}
                name="plan"
                type="radio"
                className="relative size-4 appearance-none rounded-full border border-gray-300 bg-white before:absolute before:inset-1 before:rounded-full before:bg-white not-checked:before:hidden checked:border-indigo-600 checked:bg-indigo-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:border-gray-300 disabled:bg-gray-100 disabled:before:bg-gray-400 dark:border-white/10 dark:bg-white/5 dark:checked:border-indigo-500 dark:checked:bg-indigo-500 dark:focus-visible:outline-indigo-500 dark:disabled:border-white/5 dark:disabled:bg-white/10 dark:disabled:before:bg-white/20 forced-colors:appearance-auto forced-colors:before:hidden"
              />
            </div>
          </div>
        ))}
      </div>
    </fieldset>
  )
}
