// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const settings = [
  { id: 'public', name: 'Public access', description: 'This project would be available to anyone who has the link' },
  {
    id: 'private-to-project-members',
    name: 'Private to project members',
    description: 'Only members of this project would be able to access',
  },
  { id: 'private-to-you', name: 'Private to you', description: 'You are the only one able to access this project' },
]

export function ListWithDescriptionsInPanel08() {
  return (
    <fieldset aria-label="Privacy setting" className="-space-y-px rounded-md bg-white dark:bg-gray-800/50">
      {settings.map((setting) => (
        <label
          key={setting.id}
          aria-label={setting.name}
          aria-description={setting.description}
          className="group flex border border-gray-200 p-4 first:rounded-tl-md first:rounded-tr-md last:rounded-br-md last:rounded-bl-md focus:outline-hidden has-checked:relative has-checked:border-indigo-200 has-checked:bg-indigo-50 dark:border-gray-700 dark:has-checked:border-indigo-800 dark:has-checked:bg-indigo-500/10"
        >
          <input
            defaultValue={setting.id}
            defaultChecked={setting.id === 'public'}
            name="privacy-setting"
            type="radio"
            className="relative mt-0.5 size-4 shrink-0 appearance-none rounded-full border border-gray-300 bg-white before:absolute before:inset-1 before:rounded-full before:bg-white not-checked:before:hidden checked:border-indigo-600 checked:bg-indigo-600 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 disabled:border-gray-300 disabled:bg-gray-100 disabled:before:bg-gray-400 dark:border-white/10 dark:bg-white/5 dark:checked:border-indigo-500 dark:checked:bg-indigo-500 dark:focus-visible:outline-indigo-500 dark:disabled:border-white/5 dark:disabled:bg-white/10 dark:disabled:before:bg-white/20 forced-colors:appearance-auto forced-colors:before:hidden"
          />
          <span className="ml-3 flex flex-col">
            <span className="block text-sm font-medium text-gray-900 group-has-checked:text-indigo-900 dark:text-white dark:group-has-checked:text-indigo-300">
              {setting.name}
            </span>
            <span className="block text-sm text-gray-500 group-has-checked:text-indigo-700 dark:text-gray-400 dark:group-has-checked:text-indigo-300/75">
              {setting.description}
            </span>
          </span>
        </label>
      ))}
    </fieldset>
  )
}
