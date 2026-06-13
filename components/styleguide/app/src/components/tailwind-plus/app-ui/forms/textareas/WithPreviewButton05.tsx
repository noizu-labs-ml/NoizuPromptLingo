// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { Tab, TabGroup, TabList, TabPanel, TabPanels } from '@headlessui/react'
import { AtSymbolIcon, CodeBracketIcon, LinkIcon } from '@heroicons/react/20/solid'

export function WithPreviewButton05() {
  return (
    <form action="#">
      <TabGroup>
        <div className="group flex items-center">
          <TabList className="flex gap-2">
            <Tab className="rounded-md border border-transparent bg-white px-3 py-1.5 text-sm font-medium text-gray-500 hover:bg-gray-100 hover:text-gray-900 data-selected:bg-gray-100 data-selected:text-gray-900 data-selected:hover:bg-gray-200 dark:bg-gray-900 dark:text-gray-400 dark:hover:bg-white/10 dark:hover:text-white dark:data-selected:bg-white/10 dark:data-selected:text-white dark:data-selected:hover:bg-white/10">
              Write
            </Tab>
            <Tab className="rounded-md border border-transparent bg-white px-3 py-1.5 text-sm font-medium text-gray-500 hover:bg-gray-100 hover:text-gray-900 data-selected:bg-gray-100 data-selected:text-gray-900 data-selected:hover:bg-gray-200 dark:bg-gray-900 dark:text-gray-400 dark:hover:bg-white/10 dark:hover:text-white dark:data-selected:bg-white/10 dark:data-selected:text-white dark:data-selected:hover:bg-white/10">
              Preview
            </Tab>
          </TabList>

          {/* These buttons are here simply as examples and don't actually do anything. */}
          <div className="ml-auto hidden items-center space-x-5 group-has-[*:first-child[aria-selected='true']]:flex">
            <div className="flex items-center">
              <button
                type="button"
                className="-m-2.5 inline-flex size-10 items-center justify-center rounded-full text-gray-400 hover:text-gray-500 dark:text-gray-500 dark:hover:text-white"
              >
                <span className="sr-only">Insert link</span>
                <LinkIcon aria-hidden="true" className="size-5" />
              </button>
            </div>
            <div className="flex items-center">
              <button
                type="button"
                className="-m-2.5 inline-flex size-10 items-center justify-center rounded-full text-gray-400 hover:text-gray-500 dark:text-gray-500 dark:hover:text-white"
              >
                <span className="sr-only">Insert code</span>
                <CodeBracketIcon aria-hidden="true" className="size-5" />
              </button>
            </div>
            <div className="flex items-center">
              <button
                type="button"
                className="-m-2.5 inline-flex size-10 items-center justify-center rounded-full text-gray-400 hover:text-gray-500 dark:text-gray-500 dark:hover:text-white"
              >
                <span className="sr-only">Mention someone</span>
                <AtSymbolIcon aria-hidden="true" className="size-5" />
              </button>
            </div>
          </div>
        </div>
        <TabPanels className="mt-2">
          <TabPanel className="-m-0.5 rounded-lg p-0.5">
            <label htmlFor="comment" className="sr-only">
              Comment
            </label>
            <div>
              <textarea
                id="comment"
                name="comment"
                rows={5}
                placeholder="Add your comment..."
                className="block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6 dark:bg-white/5 dark:text-white dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500"
                defaultValue={''}
              />
            </div>
          </TabPanel>
          <TabPanel className="-m-0.5 rounded-lg p-0.5">
            <div className="border-b border-gray-200 dark:border-white/10">
              <div className="mx-px mt-px px-3 pt-2 pb-12 text-sm text-gray-800 dark:text-gray-300">
                Preview content will render here.
              </div>
            </div>
          </TabPanel>
        </TabPanels>
      </TabGroup>
      <div className="mt-2 flex justify-end">
        <button
          type="submit"
          className="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:shadow-none dark:hover:bg-indigo-400 dark:focus-visible:outline-indigo-500"
        >
          Post
        </button>
      </div>
    </form>
  )
}
