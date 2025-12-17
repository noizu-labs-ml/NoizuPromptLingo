'use client';

import { useEffect, useState, useCallback } from 'react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import {
  RefreshCw,
  ArrowLeft,
  Send,
  GitBranch,
  FileBox,
  Clock,
  User,
  CheckCircle,
} from 'lucide-react';
import {
  Task,
  TaskEvent,
  getTask,
  getTaskFeed,
  updateTaskStatus,
  updateTask,
  addTaskMessage,
} from '@/lib/api';
import { StatusBadge, PriorityBadge, ComplexityBadge } from '@/components/Badge';
import { Button } from '@/components/Button';
import { Input, Textarea, Select } from '@/components/Input';

const STATUS_TRANSITIONS: Record<string, string[]> = {
  pending: ['in_progress'],
  in_progress: ['blocked', 'review'],
  blocked: ['in_progress'],
  review: ['in_progress', 'done'],
  done: [],
};

export default function TaskDetailPage() {
  const params = useParams();
  const queueId = Number(params.queueId);
  const taskId = Number(params.taskId);

  const [task, setTask] = useState<Task | null>(null);
  const [events, setEvents] = useState<TaskEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState('');
  const [sending, setSending] = useState(false);
  const [editing, setEditing] = useState(false);
  const [editData, setEditData] = useState({
    title: '',
    description: '',
    acceptance_criteria: '',
    priority: '1',
  });

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      const [taskData, feedData] = await Promise.all([
        getTask(taskId),
        getTaskFeed(taskId),
      ]);
      setTask(taskData);
      setEvents(feedData.events);
      setEditData({
        title: taskData.title,
        description: taskData.description || '',
        acceptance_criteria: taskData.acceptance_criteria || '',
        priority: String(taskData.priority),
      });
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load task');
    } finally {
      setLoading(false);
    }
  }, [taskId]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleStatusChange = async (newStatus: string) => {
    try {
      await updateTaskStatus(taskId, newStatus);
      fetchData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update status');
    }
  };

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message.trim()) return;

    try {
      setSending(true);
      await addTaskMessage(taskId, message.trim(), 'user');
      setMessage('');
      fetchData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to send message');
    } finally {
      setSending(false);
    }
  };

  const handleSaveEdit = async () => {
    try {
      await updateTask(taskId, {
        title: editData.title,
        description: editData.description || undefined,
        acceptance_criteria: editData.acceptance_criteria || undefined,
        priority: Number(editData.priority),
      });
      setEditing(false);
      fetchData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update task');
    }
  };

  if (loading && !task) {
    return (
      <div className="text-center py-12">
        <RefreshCw className="h-8 w-8 animate-spin mx-auto text-gray-400" />
        <p className="mt-2 text-gray-500">Loading task...</p>
      </div>
    );
  }

  if (!task) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">Task not found</p>
        <Link href={`/tasks/${queueId}`} className="text-blue-600 hover:underline">
          Back to queue
        </Link>
      </div>
    );
  }

  const allowedTransitions = STATUS_TRANSITIONS[task.status] || [];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-start">
        <div>
          <Link
            href={`/tasks/${queueId}`}
            className="text-sm text-gray-500 hover:text-gray-700 inline-flex items-center mb-2"
          >
            <ArrowLeft className="h-4 w-4 mr-1" />
            Back to Queue
          </Link>
          {editing ? (
            <Input
              value={editData.title}
              onChange={(e) => setEditData({ ...editData, title: e.target.value })}
              className="text-2xl font-bold"
            />
          ) : (
            <h1 className="text-2xl font-bold text-gray-900">{task.title}</h1>
          )}
        </div>
        <div className="flex space-x-2">
          <Button variant="ghost" onClick={fetchData} disabled={loading}>
            <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
          </Button>
          {editing ? (
            <>
              <Button onClick={handleSaveEdit}>Save</Button>
              <Button variant="secondary" onClick={() => setEditing(false)}>
                Cancel
              </Button>
            </>
          ) : (
            <Button variant="secondary" onClick={() => setEditing(true)}>
              Edit
            </Button>
          )}
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Status and actions */}
          <div className="bg-white rounded-lg shadow-sm border p-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <StatusBadge status={task.status} />
                <PriorityBadge priority={task.priority} />
                {task.complexity && <ComplexityBadge complexity={task.complexity} />}
              </div>
              {allowedTransitions.length > 0 && (
                <div className="flex space-x-2">
                  {allowedTransitions.map((status) => (
                    <Button
                      key={status}
                      variant={status === 'done' ? 'primary' : 'secondary'}
                      size="sm"
                      onClick={() => handleStatusChange(status)}
                    >
                      {status === 'done' && <CheckCircle className="h-4 w-4 mr-1" />}
                      {status.replace('_', ' ')}
                    </Button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Description */}
          <div className="bg-white rounded-lg shadow-sm border p-4">
            <h3 className="text-sm font-medium text-gray-700 mb-2">Description</h3>
            {editing ? (
              <Textarea
                value={editData.description}
                onChange={(e) => setEditData({ ...editData, description: e.target.value })}
                placeholder="Task description"
              />
            ) : (
              <p className="text-gray-600 whitespace-pre-wrap">
                {task.description || 'No description'}
              </p>
            )}
          </div>

          {/* Acceptance Criteria */}
          <div className="bg-white rounded-lg shadow-sm border p-4">
            <h3 className="text-sm font-medium text-gray-700 mb-2">Acceptance Criteria</h3>
            {editing ? (
              <Textarea
                value={editData.acceptance_criteria}
                onChange={(e) =>
                  setEditData({ ...editData, acceptance_criteria: e.target.value })
                }
                placeholder="What needs to be true for this task to be complete?"
              />
            ) : (
              <p className="text-gray-600 whitespace-pre-wrap">
                {task.acceptance_criteria || 'No acceptance criteria defined'}
              </p>
            )}
          </div>

          {/* Artifacts */}
          {task.artifacts && task.artifacts.length > 0 && (
            <div className="bg-white rounded-lg shadow-sm border p-4">
              <h3 className="text-sm font-medium text-gray-700 mb-3">Artifacts</h3>
              <div className="space-y-2">
                {task.artifacts.map((artifact) => (
                  <div
                    key={artifact.id}
                    className="flex items-center p-2 bg-gray-50 rounded"
                  >
                    {artifact.artifact_type === 'git_branch' ? (
                      <GitBranch className="h-4 w-4 text-green-600 mr-2" />
                    ) : (
                      <FileBox className="h-4 w-4 text-blue-600 mr-2" />
                    )}
                    <div>
                      <span className="text-sm font-medium">
                        {artifact.git_branch || `Artifact #${artifact.artifact_id}`}
                      </span>
                      {artifact.description && (
                        <p className="text-xs text-gray-500">{artifact.description}</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Activity feed */}
          <div className="bg-white rounded-lg shadow-sm border p-4">
            <h3 className="text-sm font-medium text-gray-700 mb-3">Activity</h3>
            <div className="space-y-4 max-h-96 overflow-y-auto">
              {events.map((event) => (
                <div key={event.id} className="flex space-x-3">
                  <div className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center flex-shrink-0">
                    <User className="h-4 w-4 text-gray-500" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center">
                      <span className="text-sm font-medium text-gray-900">
                        {event.persona || 'System'}
                      </span>
                      <span className="text-xs text-gray-400 ml-2">
                        {new Date(event.created_at).toLocaleString()}
                      </span>
                    </div>
                    <p className="text-sm text-gray-600">
                      <span className="font-medium capitalize">
                        {event.event_type.replace('_', ' ')}
                      </span>
                      {event.summary && `: ${event.summary}`}
                    </p>
                  </div>
                </div>
              ))}
              {events.length === 0 && (
                <p className="text-sm text-gray-400 text-center py-4">No activity yet</p>
              )}
            </div>

            {/* Message input */}
            <form onSubmit={handleSendMessage} className="mt-4 flex space-x-2">
              <Input
                placeholder="Add a comment or question..."
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                className="flex-1"
              />
              <Button type="submit" disabled={sending || !message.trim()}>
                <Send className="h-4 w-4" />
              </Button>
            </form>
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-4">
          <div className="bg-white rounded-lg shadow-sm border p-4">
            <h3 className="text-sm font-medium text-gray-700 mb-3">Details</h3>
            <dl className="space-y-3">
              {editing ? (
                <Select
                  label="Priority"
                  value={editData.priority}
                  onChange={(e) => setEditData({ ...editData, priority: e.target.value })}
                  options={[
                    { value: '0', label: 'Low' },
                    { value: '1', label: 'Normal' },
                    { value: '2', label: 'High' },
                    { value: '3', label: 'Urgent' },
                  ]}
                />
              ) : (
                <>
                  <div>
                    <dt className="text-xs text-gray-500">Priority</dt>
                    <dd>
                      <PriorityBadge priority={task.priority} />
                    </dd>
                  </div>
                  {task.complexity && (
                    <div>
                      <dt className="text-xs text-gray-500">Complexity</dt>
                      <dd>
                        <ComplexityBadge complexity={task.complexity} />
                      </dd>
                    </div>
                  )}
                </>
              )}
              {task.assigned_to && (
                <div>
                  <dt className="text-xs text-gray-500">Assigned To</dt>
                  <dd className="text-sm flex items-center">
                    <User className="h-4 w-4 mr-1 text-gray-400" />
                    {task.assigned_to}
                  </dd>
                </div>
              )}
              {task.deadline && (
                <div>
                  <dt className="text-xs text-gray-500">Deadline</dt>
                  <dd className="text-sm flex items-center">
                    <Clock className="h-4 w-4 mr-1 text-gray-400" />
                    {new Date(task.deadline).toLocaleString()}
                  </dd>
                </div>
              )}
              <div>
                <dt className="text-xs text-gray-500">Created</dt>
                <dd className="text-sm">{new Date(task.created_at).toLocaleString()}</dd>
              </div>
              <div>
                <dt className="text-xs text-gray-500">Updated</dt>
                <dd className="text-sm">{new Date(task.updated_at).toLocaleString()}</dd>
              </div>
            </dl>
          </div>
        </div>
      </div>
    </div>
  );
}
