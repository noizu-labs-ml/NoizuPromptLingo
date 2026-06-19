# web/ — Next.js Dashboard

```
web/
├── app/                        # Next.js App Router
│   ├── api/                    #   API route handlers (proxy to Elixir backend)
│   ├── assets/                 #   Asset management pages
│   ├── chat/                   #   Chat room UI
│   ├── dashboard/              #   Main dashboard views
│   ├── projects/               #   Project management pages
│   ├── reviews/                #   Code review UI
│   ├── settings/               #   Settings pages
│   ├── tickets/                #   Ticket management UI
│   ├── globals.css             #   Global styles
│   ├── layout.jsx              #   Root layout (sidebar + content)
│   └── page.jsx                #   Landing page
├── components/
│   ├── sidebar.jsx             #   Navigation sidebar
│   └── sidebar.module.css      #   Sidebar styles
├── lib/
│   └── api.js                  #   Backend API client
├── auth.js                     # Authentication helpers
├── middleware.js                # Next.js middleware (auth guards)
├── next.config.mjs             # Next.js configuration
├── package.json                # Node dependencies
└── package-lock.json
```
