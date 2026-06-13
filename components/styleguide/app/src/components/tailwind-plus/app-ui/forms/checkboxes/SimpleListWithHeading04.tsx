// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const people = [
  { id: 1, name: 'Annette Black', selected: true },
  { id: 2, name: 'Cody Fisher', selected: true },
  { id: 3, name: 'Courtney Henry', selected: false },
  { id: 4, name: 'Kathryn Murphy', selected: false },
  { id: 5, name: 'Theresa Webb', selected: false },
]

export function SimpleListWithHeading04() {
  return (
    <fieldset>
      <legend className="text-base font-semibold text-gray-900 dark:text-white">Members</legend>
      <div className="mt-4 divide-y divide-gray-200 border-t border-b border-gray-200 dark:divide-white/10 dark:border-white/10">
        {people.map((person, personIdx) => (
          <div key={personIdx} className="relative flex gap-3 py-4">
            <div className="min-w-0 flex-1 text-sm/6">
              <label htmlFor={`person-${person.id}`} className="font-medium text-gray-900 select-none dark:text-white">
                {person.name}
              </label>
            </div>
            <div className="flex h-6 shrink-0 items-center">
              <div className="group grid size-4 grid-cols-1">
                <input
                  defaultChecked={person.selected}
                  id={`person-${person.id}`}
                  name={`person-${person.id}`}
                  type="checkbox"
                  className="col-start-1 row-start-1 appearance-none rounded-sm border border-gray-300 bg-white checked:border-indigo-600 checked:bg-indigo-600 indeterminate:border-indigo-600 indeterminate:bg-indigo-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:border-gray-300 disabled:bg-gray-100 disabled:checked:bg-gray-100 dark:border-white/10 dark:bg-white/5 dark:checked:border-indigo-500 dark:checked:bg-indigo-500 dark:indeterminate:border-indigo-500 dark:indeterminate:bg-indigo-500 dark:focus-visible:outline-indigo-500 dark:disabled:border-white/5 dark:disabled:bg-white/10 dark:disabled:checked:bg-white/10 forced-colors:appearance-auto"
                />
                <svg
                  fill="none"
                  viewBox="0 0 14 14"
                  className="pointer-events-none col-start-1 row-start-1 size-3.5 self-center justify-self-center stroke-white group-has-disabled:stroke-gray-950/25 dark:group-has-disabled:stroke-white/25"
                >
                  <path
                    d="M3 8L6 11L11 3.5"
                    strokeWidth={2}
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    className="opacity-0 group-has-checked:opacity-100"
                  />
                  <path
                    d="M3 7H11"
                    strokeWidth={2}
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    className="opacity-0 group-has-indeterminate:opacity-100"
                  />
                </svg>
              </div>
            </div>
          </div>
        ))}
      </div>
    </fieldset>
  )
}
