import {expect} from '@open-wc/testing';
import {groupBoards, ticketTags, statusKind, priorityKind, initials} from '../src/grouping.js';
import type {QueueBoardData} from '../src/types.js';

const data: QueueBoardData = {
  queues: [
    {
      id: 'b1',
      name: 'Board One',
      stages: [
        {id: 's2', name: 'Second', position: 1},
        {id: 's1', name: 'First', position: 0},
      ],
    },
    {id: 'b2', name: 'Board Two'},
  ],
  items: [
    {id: 't1', title: 'A', queue_id: 'b1', stage_id: 's1'},
    {id: 't2', title: 'B', queue_id: 'b1', stage_id: 's2'},
    {id: 't3', title: 'C', queue_id: 'b1', stage_id: 'missing'},
    {id: 't4', title: 'D', queue_id: 'b1'},
    {id: 't5', title: 'E', queue_id: 'unknown-board'},
    {id: 't6', title: 'F', queue_id: 'b2'},
  ],
};

describe('grouping', () => {
  it('orders stages by position and appends unstaged last', () => {
    const [board] = groupBoards(data);
    expect(board?.columns.map(c => c.stage?.name ?? 'Unstaged')).to.deep.equal([
      'First',
      'Second',
      'Unstaged',
    ]);
    const unstaged = board?.columns[2];
    expect(unstaged?.tickets.map(t => t.id)).to.deep.equal(['t3', 't4']);
  });

  it('boards without stages still collect their tickets', () => {
    const groups = groupBoards(data);
    const two = groups[1];
    expect(two?.columns).to.have.lengthOf(1);
    expect(two?.columns[0]?.tickets.map(t => t.id)).to.deep.equal(['t6']);
  });

  it('drops tickets whose queue is unknown', () => {
    const ids = groupBoards(data).flatMap(g => g.columns.flatMap(c => c.tickets.map(t => t.id)));
    expect(ids).to.not.include('t5');
  });

  it('filters to a single board id', () => {
    const groups = groupBoards(data, 'b2');
    expect(groups).to.have.lengthOf(1);
    expect(groups[0]?.board.name).to.equal('Board Two');
  });

  it('reports totalCount per board', () => {
    const groups = groupBoards(data);
    expect(groups[0]?.totalCount).to.equal(4);
    expect(groups[1]?.totalCount).to.equal(1);
  });
});

describe('ticketTags', () => {
  it('reads the tags field', () => {
    expect(ticketTags({id: 't', title: 'x', tags: ['a', 'b']})).to.deep.equal(['a', 'b']);
  });

  it('falls back to custom_fields.tags', () => {
    expect(
      ticketTags({id: 't', title: 'x', custom_fields: {tags: ['ci', 'deploy']}}),
    ).to.deep.equal(['ci', 'deploy']);
  });

  it('filters non-string entries and returns empty when absent', () => {
    expect(ticketTags({id: 't', title: 'x', tags: ['a', 3, null] as unknown as string[]})).to.deep.equal(['a']);
    expect(ticketTags({id: 't', title: 'x'})).to.deep.equal([]);
    expect(ticketTags({id: 't', title: 'x', custom_fields: {other: 1}})).to.deep.equal([]);
  });
});

describe('status/priority classification', () => {
  it('maps statuses to kinds', () => {
    expect(statusKind('done')).to.equal('done');
    expect(statusKind('in_progress')).to.equal('active');
    expect(statusKind('blocked')).to.equal('blocked');
    expect(statusKind('open')).to.equal('open');
    expect(statusKind(null)).to.equal('open');
  });

  it('maps priorities to chip kinds', () => {
    expect(priorityKind('urgent')).to.equal('high');
    expect(priorityKind('medium')).to.equal('medium');
    expect(priorityKind('minor')).to.equal('low');
    expect(priorityKind(null)).to.equal(null);
    expect(priorityKind('none')).to.equal(null);
  });
});

describe('initials', () => {
  it('takes the first letters of the first two words', () => {
    expect(initials('Ada Lovelace')).to.equal('AL');
    expect(initials('cher')).to.equal('C');
    expect(initials('  ')).to.equal('?');
  });
});
