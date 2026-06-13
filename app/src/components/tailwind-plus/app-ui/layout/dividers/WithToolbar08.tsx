// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { ChatBubbleBottomCenterTextIcon, PaperClipIcon, PencilIcon, TrashIcon } from '@heroicons/react/20/solid'

export function WithToolbar08() {
  return (
    <div className="flex items-center">
      <div aria-hidden="true" className="w-full border-t border-gray-300 dark:border-white/15" />
      <div className="relative flex justify-center">
        <span className="isolate inline-flex -space-x-px rounded-md shadow-xs dark:shadow-none">
          <button
            type="button"
            className="relative inline-flex items-center rounded-l-md bg-white px-3 py-2 text-gray-400 inset-ring inset-ring-gray-300 hover:bg-gray-50 focus:z-10 dark:bg-white/5 dark:inset-ring-gray-700 dark:hover:bg-white/10"
          >
            <span className="sr-only">Edit</span>
            <PencilIcon aria-hidden="true" className="size-5" />
          </button>
          <button
            type="button"
            className="relative inline-flex items-center bg-white px-3 py-2 text-gray-400 inset-ring inset-ring-gray-300 hover:bg-gray-50 focus:z-10 dark:bg-white/5 dark:inset-ring-gray-700 dark:hover:bg-white/10"
          >
            <span className="sr-only">Attachment</span>
            <PaperClipIcon aria-hidden="true" className="size-5" />
          </button>
          <button
            type="button"
            className="relative inline-flex items-center bg-white px-3 py-2 text-gray-400 inset-ring inset-ring-gray-300 hover:bg-gray-50 focus:z-10 dark:bg-white/5 dark:inset-ring-gray-700 dark:hover:bg-white/10"
          >
            <span className="sr-only">Annotate</span>
            <ChatBubbleBottomCenterTextIcon aria-hidden="true" className="size-5" />
          </button>
          <button
            type="button"
            className="relative inline-flex items-center rounded-r-md bg-white px-3 py-2 text-gray-400 inset-ring inset-ring-gray-300 hover:bg-gray-50 focus:z-10 dark:bg-white/5 dark:inset-ring-gray-700 dark:hover:bg-white/10"
          >
            <span className="sr-only">Delete</span>
            <TrashIcon aria-hidden="true" className="size-5" />
          </button>
        </span>
      </div>
      <div aria-hidden="true" className="w-full border-t border-gray-300 dark:border-white/15" />
    </div>
  )
}
