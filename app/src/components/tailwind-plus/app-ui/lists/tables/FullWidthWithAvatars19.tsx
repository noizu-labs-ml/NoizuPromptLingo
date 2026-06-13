// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

const activityItems = [
  {
    user: {
      name: 'Michael Foster',
      imageUrl:
        'https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
    },
    commit: '2d89f0c8',
    branch: 'main',
    status: 'Completed',
    duration: '25s',
    date: '45 minutes ago',
    dateTime: '2023-01-23T11:00',
  },
  {
    user: {
      name: 'Lindsay Walton',
      imageUrl:
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
    },
    commit: '249df660',
    branch: 'main',
    status: 'Completed',
    duration: '1m 32s',
    date: '3 hours ago',
    dateTime: '2023-01-23T09:00',
  },
  {
    user: {
      name: 'Courtney Henry',
      imageUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
    },
    commit: '11464223',
    branch: 'main',
    status: 'Error',
    duration: '1m 4s',
    date: '12 hours ago',
    dateTime: '2023-01-23T00:00',
  },
  {
    user: {
      name: 'Courtney Henry',
      imageUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
    },
    commit: 'dad28e95',
    branch: 'main',
    status: 'Completed',
    duration: '2m 15s',
    date: '2 days ago',
    dateTime: '2023-01-21T13:00',
  },
  {
    user: {
      name: 'Michael Foster',
      imageUrl:
        'https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
    },
    commit: '624bc94c',
    branch: 'main',
    status: 'Completed',
    duration: '1m 12s',
    date: '5 days ago',
    dateTime: '2023-01-18T12:34',
  },
  {
    user: {
      name: 'Courtney Henry',
      imageUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
    },
    commit: 'e111f80e',
    branch: 'main',
    status: 'Completed',
    duration: '1m 56s',
    date: '1 week ago',
    dateTime: '2023-01-16T15:54',
  },
  {
    user: {
      name: 'Michael Foster',
      imageUrl:
        'https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
    },
    commit: '5e136005',
    branch: 'main',
    status: 'Completed',
    duration: '3m 45s',
    date: '1 week ago',
    dateTime: '2023-01-16T11:31',
  },
  {
    user: {
      name: 'Whitney Francis',
      imageUrl:
        'https://images.unsplash.com/photo-1517365830460-955ce3ccd263?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
    },
    commit: '5c1fd07f',
    branch: 'main',
    status: 'Completed',
    duration: '37s',
    date: '2 weeks ago',
    dateTime: '2023-01-09T08:45',
  },
]

export function FullWidthWithAvatars19() {
  return (
    <div className="bg-white py-10 dark:bg-gray-900">
      <h2 className="px-4 text-base/7 font-semibold text-gray-900 sm:px-6 lg:px-8 dark:text-white">Latest activity</h2>
      <table className="mt-6 w-full text-left whitespace-nowrap">
        <colgroup>
          <col className="w-full sm:w-4/12" />
          <col className="lg:w-4/12" />
          <col className="lg:w-2/12" />
          <col className="lg:w-1/12" />
          <col className="lg:w-1/12" />
        </colgroup>
        <thead className="border-b border-gray-200 text-sm/6 text-gray-900 dark:border-white/15 dark:text-white">
          <tr>
            <th scope="col" className="py-2 pr-8 pl-4 font-semibold sm:pl-6 lg:pl-8">
              User
            </th>
            <th scope="col" className="hidden py-2 pr-8 pl-0 font-semibold sm:table-cell">
              Commit
            </th>
            <th scope="col" className="py-2 pr-4 pl-0 text-right font-semibold sm:pr-8 sm:text-left lg:pr-20">
              Status
            </th>
            <th scope="col" className="hidden py-2 pr-8 pl-0 font-semibold md:table-cell lg:pr-20">
              Duration
            </th>
            <th scope="col" className="hidden py-2 pr-4 pl-0 text-right font-semibold sm:table-cell sm:pr-6 lg:pr-8">
              Deployed at
            </th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100 dark:divide-white/10">
          {activityItems.map((item) => (
            <tr key={item.commit}>
              <td className="py-4 pr-8 pl-4 sm:pl-6 lg:pl-8">
                <div className="flex items-center gap-x-4">
                  <img
                    alt=""
                    src={item.user.imageUrl}
                    className="size-8 rounded-full bg-gray-100 dark:bg-gray-800 dark:outline dark:outline-white/10"
                  />
                  <div className="truncate text-sm/6 font-medium text-gray-900 dark:text-white">{item.user.name}</div>
                </div>
              </td>
              <td className="hidden py-4 pr-4 pl-0 sm:table-cell sm:pr-8">
                <div className="flex gap-x-3">
                  <div className="font-mono text-sm/6 text-gray-500 dark:text-gray-400">{item.commit}</div>
                  <div className="rounded-md bg-gray-100 px-2 py-1 text-xs font-medium text-gray-600 outline-1 outline-gray-200 dark:bg-gray-700/40 dark:text-gray-400 dark:-outline-offset-1 dark:outline-white/10">
                    {item.branch}
                  </div>
                </div>
              </td>
              <td className="py-4 pr-4 pl-0 text-sm/6 sm:pr-8 lg:pr-20">
                <div className="flex items-center justify-end gap-x-2 sm:justify-start">
                  <time dateTime={item.dateTime} className="text-gray-500 sm:hidden dark:text-gray-400">
                    {item.date}
                  </time>
                  {item.status === 'Completed' ? (
                    <div className="flex-none rounded-full bg-green-600/10 p-1 text-green-600 dark:bg-green-400/10 dark:text-green-400">
                      <div className="size-1.5 rounded-full bg-current" />
                    </div>
                  ) : null}
                  {item.status === 'Error' ? (
                    <div className="flex-none rounded-full bg-rose-600/10 p-1 text-rose-600 dark:bg-rose-400/10 dark:text-rose-400">
                      <div className="size-1.5 rounded-full bg-current" />
                    </div>
                  ) : null}
                  <div className="hidden text-gray-900 sm:block dark:text-white">{item.status}</div>
                </div>
              </td>
              <td className="hidden py-4 pr-8 pl-0 text-sm/6 text-gray-500 md:table-cell lg:pr-20 dark:text-gray-400">
                {item.duration}
              </td>
              <td className="hidden py-4 pr-4 pl-0 text-right text-sm/6 text-gray-500 sm:table-cell sm:pr-6 lg:pr-8 dark:text-gray-400">
                <time dateTime={item.dateTime}>{item.date}</time>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
