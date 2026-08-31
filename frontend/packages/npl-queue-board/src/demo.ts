import {NplQueueBoard} from './npl-queue-board.js';
import {createMockProvider} from './providers/mock-provider.js';

const el = document.querySelector<NplQueueBoard>('npl-queue-board');
if (!el) throw new Error('demo: npl-queue-board element not found');

el.dataProvider = createMockProvider({delayMs: 500});

el.addEventListener('card-activate', event => {
  const {ticket} = (event as CustomEvent).detail;
  const out = document.getElementById('event-log');
  if (out) out.textContent = `card-activate: ${ticket.key ?? ticket.id} — ${ticket.title}`;
});

el.addEventListener('queue-load-error', event => {
  const out = document.getElementById('event-log');
  if (out) out.textContent = `queue-load-error: ${(event as CustomEvent).detail.error}`;
});

const log = document.getElementById('event-log');
const boardEl: NplQueueBoard | null = el;
for (const button of document.querySelectorAll<HTMLButtonElement>('[data-theme]')) {
  button.addEventListener('click', () => {
    const theme = button.dataset.theme as 'auto' | 'light' | 'dark';
    boardEl?.setAttribute('theme', theme);
    document.body.dataset.theme = theme === 'auto' ? '' : theme;
    if (log && theme === 'dark') log.textContent = 'dark mode — tokens re-skin the component';
  });
}
