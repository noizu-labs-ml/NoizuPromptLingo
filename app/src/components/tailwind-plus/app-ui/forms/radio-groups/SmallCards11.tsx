// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const memoryOptions = [
  { id: '4gb', name: '4 GB', inStock: true },
  { id: '8gb', name: '8 GB', inStock: true },
  { id: '16gb', name: '16 GB', inStock: true },
  { id: '32gb', name: '32 GB', inStock: true },
  { id: '64gb', name: '64 GB', inStock: true },
  { id: '128gb', name: '128 GB', inStock: false },
]

export function SmallCards11() {
  return (
    <fieldset aria-label="Choose a memory option">
      <div className="flex items-center justify-between">
        <div className="text-sm/6 font-medium text-gray-900 dark:text-white">RAM</div>
        <a
          href="#"
          className="text-sm/6 font-medium text-indigo-600 hover:text-indigo-500 dark:text-indigo-400 dark:hover:text-indigo-300"
        >
          See performance specs
        </a>
      </div>
      <div className="mt-2 grid grid-cols-3 gap-3 sm:grid-cols-6">
        {memoryOptions.map((option) => (
          <label
            key={option.id}
            aria-label={option.name}
            className="group relative flex items-center justify-center rounded-md border border-gray-300 bg-white p-3 has-checked:border-indigo-600 has-checked:bg-indigo-600 has-focus-visible:outline-2 has-focus-visible:outline-offset-2 has-focus-visible:outline-indigo-600 has-disabled:border-gray-400 has-disabled:bg-gray-200 has-disabled:opacity-25 dark:border-white/10 dark:bg-gray-800/50 dark:has-checked:border-indigo-500 dark:has-checked:bg-indigo-500 dark:has-focus-visible:outline-indigo-500 dark:has-disabled:border-white/10 dark:has-disabled:bg-gray-800"
          >
            <input
              defaultValue={option.id}
              defaultChecked={option === memoryOptions[2]}
              name="option"
              type="radio"
              disabled={!option.inStock}
              className="absolute inset-0 appearance-none focus:outline-none disabled:cursor-not-allowed"
            />
            <span className="text-sm font-medium text-gray-900 uppercase group-has-checked:text-white dark:text-white">
              {option.name}
            </span>
          </label>
        ))}
      </div>
    </fieldset>
  )
}
