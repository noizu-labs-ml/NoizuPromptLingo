// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { StarIcon } from '@heroicons/react/20/solid'

const reviews = [
  {
    id: 1,
    title: "Can't say enough good things",
    rating: 5,
    content: `
      <p>I was really pleased with the overall shopping experience. My order even included a little personal, handwritten note, which delighted me!</p>
      <p>The product quality is amazing, it looks and feel even better than I had anticipated. Brilliant stuff! I would gladly recommend this store to my friends. And, now that I think of it... I actually have, many times!</p>
    `,
    author: 'Risako M',
    date: 'May 16, 2021',
    datetime: '2021-01-06',
  },
  {
    id: 2,
    title: 'Very comfy and looks the part',
    rating: 5,
    content: `
      <p>After a quick chat with customer support, I had a good feeling about this shirt and ordered three of them.</p>
      <p>Less than 48 hours later, my delivery arrived. I haven't worn anything else since that day! These shirts are so comfortable, yet look classy enough that I can wear them at work or even some formal events. Winning!</p>
    `,
    author: 'Jackie H',
    date: 'April 6, 2021',
    datetime: '2021-01-06',
  },
  {
    id: 3,
    title: 'The last shirts I may ever need',
    rating: 4,
    content: `
      <p>I bought two of those comfy cotton shirts, and let me tell you: they're amazing! I have been wearing them almost every day. Even after a dozen of washes, that still looks and feel good as new. Will definitely order a few more... If I ever need to!</p>
    `,
    author: 'Laura G',
    date: 'February 24, 2021',
    datetime: '2021-01-06',
  },
]

function classNames(...classes) {
  return classes.filter(Boolean).join(' ')
}

export function MultiColumn01() {
  return (
    <div className="bg-white">
      <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
        <h2 className="text-lg font-medium text-gray-900">Recent reviews</h2>
        <div className="mt-6 divide-y divide-gray-200 border-t border-b border-gray-200">
          {reviews.map((review) => (
            <div key={review.id} className="py-10 lg:grid lg:grid-cols-12 lg:gap-x-8">
              <div className="lg:col-span-8 lg:col-start-5 xl:col-span-9 xl:col-start-4 xl:grid xl:grid-cols-3 xl:items-start xl:gap-x-8">
                <div className="flex items-center xl:col-span-1">
                  <div className="flex items-center">
                    {[0, 1, 2, 3, 4].map((rating) => (
                      <StarIcon
                        key={rating}
                        aria-hidden="true"
                        className={classNames(
                          review.rating > rating ? 'text-yellow-400' : 'text-gray-200',
                          'size-5 shrink-0',
                        )}
                      />
                    ))}
                  </div>
                  <p className="ml-3 text-sm text-gray-700">
                    {review.rating}
                    <span className="sr-only"> out of 5 stars</span>
                  </p>
                </div>

                <div className="mt-4 lg:mt-6 xl:col-span-2 xl:mt-0">
                  <h3 className="text-sm font-medium text-gray-900">{review.title}</h3>

                  <div
                    dangerouslySetInnerHTML={{ __html: review.content }}
                    className="mt-3 space-y-6 text-sm text-gray-500"
                  />
                </div>
              </div>

              <div className="mt-6 flex items-center text-sm lg:col-span-4 lg:col-start-1 lg:row-start-1 lg:mt-0 lg:flex-col lg:items-start xl:col-span-3">
                <p className="font-medium text-gray-900">{review.author}</p>
                <time
                  dateTime={review.datetime}
                  className="ml-4 border-l border-gray-200 pl-4 text-gray-500 lg:mt-2 lg:ml-0 lg:border-0 lg:pl-0"
                >
                  {review.date}
                </time>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
