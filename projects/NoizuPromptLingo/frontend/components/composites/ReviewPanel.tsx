"use client";

import { useState, useCallback } from "react";
import useSWR from "swr";
import clsx from "clsx";
import {
  ChatBubbleLeftRightIcon,
  CheckCircleIcon,
  ChevronDownIcon,
  ChevronRightIcon,
  PlusIcon,
} from "@heroicons/react/24/outline";

import { api } from "@/lib/api/client";
import type { Review, InlineComment } from "@/lib/api/types";
import { Card } from "@/components/primitives/Card";
import { Badge } from "@/components/primitives/Badge";
import { Button } from "@/components/primitives/Button";
import { Input } from "@/components/primitives/Input";
import { Textarea } from "@/components/primitives/Textarea";
import { FormField } from "@/components/primitives/FormField";
import { EmptyState } from "@/components/primitives/EmptyState";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface ReviewPanelProps {
  artifactId: number;
  revisionId: number;
  className?: string;
}

type ReviewStatus = "open" | "completed";

// ---------------------------------------------------------------------------
// Sub-components
// ---------------------------------------------------------------------------

function StatusBadge({ status }: { status: string }) {
  const variant = status === "completed" ? "success" : "info";
  return (
    <Badge variant={variant} dot size="sm">
      {status}
    </Badge>
  );
}

function CommentItem({ comment }: { comment: InlineComment }) {
  return (
    <div className="flex flex-col gap-1 rounded-md border border-border/50 bg-surface-0 p-3">
      <div className="flex items-center justify-between gap-2">
        <span className="text-xs font-medium text-foreground">
          {comment.persona}
        </span>
        <span className="font-mono text-[10px] text-subtle">
          {comment.location}
        </span>
      </div>
      <p className="text-sm text-muted whitespace-pre-wrap">{comment.comment}</p>
      {comment.created_at && (
        <span className="text-[10px] text-subtle font-mono">
          {new Date(comment.created_at).toLocaleString()}
        </span>
      )}
    </div>
  );
}

function ReviewCard({
  review,
  onCommentAdded,
  onCompleted,
}: {
  review: Review;
  onCommentAdded: () => void;
  onCompleted: () => void;
}) {
  const [expanded, setExpanded] = useState(false);
  const [showAddComment, setShowAddComment] = useState(false);
  const [showComplete, setShowComplete] = useState(false);

  // Add-comment form state
  const [location, setLocation] = useState("");
  const [commentText, setCommentText] = useState("");
  const [commentPersona, setCommentPersona] = useState(review.reviewer_persona);
  const [submittingComment, setSubmittingComment] = useState(false);
  const [commentError, setCommentError] = useState<string | null>(null);

  // Complete form state
  const [overallComment, setOverallComment] = useState("");
  const [submittingComplete, setSubmittingComplete] = useState(false);
  const [completeError, setCompleteError] = useState<string | null>(null);

  const isCompleted = review.review_status === "completed";
  const comments = review.comments ?? [];

  async function handleAddComment() {
    if (!location.trim() || !commentText.trim()) return;
    setSubmittingComment(true);
    setCommentError(null);
    try {
      await api.reviews.addComment(review.review_id, {
        location: location.trim(),
        comment: commentText.trim(),
        persona: commentPersona.trim() || review.reviewer_persona,
      });
      setLocation("");
      setCommentText("");
      setShowAddComment(false);
      onCommentAdded();
    } catch (err) {
      setCommentError(
        err instanceof Error ? err.message : "Failed to add comment."
      );
    } finally {
      setSubmittingComment(false);
    }
  }

  async function handleComplete() {
    setSubmittingComplete(true);
    setCompleteError(null);
    try {
      await api.reviews.complete(
        review.review_id,
        overallComment.trim() || undefined
      );
      setOverallComment("");
      setShowComplete(false);
      onCompleted();
    } catch (err) {
      setCompleteError(
        err instanceof Error ? err.message : "Failed to complete review."
      );
    } finally {
      setSubmittingComplete(false);
    }
  }

  return (
    <Card className="space-y-3">
      {/* Header */}
      <div className="flex items-center justify-between gap-2">
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => setExpanded((v) => !v)}
            className="focus-ring rounded p-0.5 text-muted hover:text-foreground transition-colors"
            aria-label={expanded ? "Collapse" : "Expand"}
          >
            {expanded ? (
              <ChevronDownIcon className="h-4 w-4" />
            ) : (
              <ChevronRightIcon className="h-4 w-4" />
            )}
          </button>
          <span className="text-sm font-semibold text-foreground">
            {review.reviewer_persona}
          </span>
          <StatusBadge status={review.review_status} />
          <span className="font-mono text-[10px] text-subtle">
            #{review.review_id}
          </span>
        </div>
        <div className="flex items-center gap-1.5">
          {comments.length > 0 && (
            <span className="text-xs text-muted flex items-center gap-1">
              <ChatBubbleLeftRightIcon className="h-3.5 w-3.5" />
              {comments.length}
            </span>
          )}
          {review.created_at && (
            <span className="font-mono text-[10px] text-subtle">
              {new Date(review.created_at).toLocaleDateString()}
            </span>
          )}
        </div>
      </div>

      {/* Overall comment */}
      {review.overall_comment && (
        <p className="text-sm text-muted italic border-l-2 border-accent/30 pl-3">
          {review.overall_comment}
        </p>
      )}

      {/* Expanded content */}
      {expanded && (
        <div className="space-y-3 pt-1">
          {/* Inline comments */}
          {comments.length > 0 ? (
            <div className="space-y-2">
              <h4 className="text-xs font-semibold text-muted uppercase tracking-wider">
                Comments
              </h4>
              {comments.map((c) => (
                <CommentItem key={c.id} comment={c} />
              ))}
            </div>
          ) : (
            <p className="text-xs text-subtle italic">No comments yet.</p>
          )}

          {/* Action buttons */}
          {!isCompleted && (
            <div className="flex items-center gap-2 pt-1">
              <Button
                size="sm"
                variant="ghost"
                onClick={() => {
                  setShowAddComment((v) => !v);
                  setShowComplete(false);
                }}
                leadingIcon={<PlusIcon className="h-3.5 w-3.5" />}
              >
                Add Comment
              </Button>
              <Button
                size="sm"
                variant="ghost"
                onClick={() => {
                  setShowComplete((v) => !v);
                  setShowAddComment(false);
                }}
                leadingIcon={<CheckCircleIcon className="h-3.5 w-3.5" />}
              >
                Complete Review
              </Button>
            </div>
          )}

          {/* Add comment form */}
          {showAddComment && !isCompleted && (
            <div className="space-y-2 rounded-md border border-border/50 bg-surface-0 p-3">
              <FormField label="Location" htmlFor={`loc-${review.review_id}`} helper="e.g. line:42, @x:100,y:200, section:intro">
                <Input
                  id={`loc-${review.review_id}`}
                  inputSize="sm"
                  value={location}
                  onChange={(e) => setLocation(e.target.value)}
                  placeholder="line:42"
                />
              </FormField>
              <FormField label="Comment" htmlFor={`cmt-${review.review_id}`}>
                <Textarea
                  id={`cmt-${review.review_id}`}
                  rows={3}
                  value={commentText}
                  onChange={(e) => setCommentText(e.target.value)}
                  placeholder="Your comment..."
                />
              </FormField>
              <FormField label="Persona" htmlFor={`per-${review.review_id}`}>
                <Input
                  id={`per-${review.review_id}`}
                  inputSize="sm"
                  value={commentPersona}
                  onChange={(e) => setCommentPersona(e.target.value)}
                  placeholder={review.reviewer_persona}
                />
              </FormField>
              {commentError && (
                <p className="text-xs text-danger" role="alert">
                  {commentError}
                </p>
              )}
              <Button
                size="sm"
                onClick={handleAddComment}
                disabled={
                  submittingComment || !location.trim() || !commentText.trim()
                }
                loading={submittingComment}
              >
                {submittingComment ? "Adding..." : "Add Comment"}
              </Button>
            </div>
          )}

          {/* Complete review form */}
          {showComplete && !isCompleted && (
            <div className="space-y-2 rounded-md border border-border/50 bg-surface-0 p-3">
              <FormField
                label="Overall Comment"
                htmlFor={`overall-${review.review_id}`}
                helper="Optional summary for the completed review."
              >
                <Textarea
                  id={`overall-${review.review_id}`}
                  rows={3}
                  value={overallComment}
                  onChange={(e) => setOverallComment(e.target.value)}
                  placeholder="Final thoughts (optional)..."
                />
              </FormField>
              {completeError && (
                <p className="text-xs text-danger" role="alert">
                  {completeError}
                </p>
              )}
              <Button
                size="sm"
                onClick={handleComplete}
                disabled={submittingComplete}
                loading={submittingComplete}
              >
                {submittingComplete ? "Completing..." : "Complete Review"}
              </Button>
            </div>
          )}
        </div>
      )}
    </Card>
  );
}

// ---------------------------------------------------------------------------
// Main component
// ---------------------------------------------------------------------------

export function ReviewPanel({
  artifactId,
  revisionId,
  className,
}: ReviewPanelProps) {
  const [showStartForm, setShowStartForm] = useState(false);
  const [reviewerPersona, setReviewerPersona] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [createError, setCreateError] = useState<string | null>(null);

  // Fetch reviews for this artifact. The backend endpoint GET /api/reviews?artifact_id=X
  // may not exist yet; gracefully fall back to an empty array.
  const {
    data: reviews,
    mutate: mutateReviews,
    isLoading,
  } = useSWR<Review[]>(
    `reviews.artifact.${artifactId}`,
    async () => {
      try {
        return await api.reviews.listByArtifact(artifactId);
      } catch {
        // Endpoint may not exist yet — return empty list
        return [];
      }
    },
    { fallbackData: [] }
  );

  const refreshReviews = useCallback(() => {
    mutateReviews();
  }, [mutateReviews]);

  async function handleStartReview() {
    if (!reviewerPersona.trim()) return;
    setSubmitting(true);
    setCreateError(null);
    try {
      await api.reviews.create({
        artifact_id: artifactId,
        revision_id: revisionId,
        reviewer_persona: reviewerPersona.trim(),
      });
      setReviewerPersona("");
      setShowStartForm(false);
      refreshReviews();
    } catch (err) {
      setCreateError(
        err instanceof Error ? err.message : "Failed to create review."
      );
    } finally {
      setSubmitting(false);
    }
  }

  const reviewList = reviews ?? [];

  return (
    <div className={clsx("space-y-4", className)}>
      {/* Header */}
      <div className="flex items-center justify-between">
        <h2 className="text-sm font-semibold text-foreground flex items-center gap-2">
          <ChatBubbleLeftRightIcon className="h-4 w-4 text-muted" />
          Reviews
          {reviewList.length > 0 && (
            <Badge variant="default" size="sm">
              {reviewList.length}
            </Badge>
          )}
        </h2>
        <Button
          size="sm"
          variant="ghost"
          onClick={() => setShowStartForm((v) => !v)}
          leadingIcon={<PlusIcon className="h-3.5 w-3.5" />}
        >
          Start Review
        </Button>
      </div>

      {/* Start review form */}
      {showStartForm && (
        <Card className="space-y-3">
          <h3 className="text-sm font-semibold text-foreground">
            Start a New Review
          </h3>
          <p className="text-xs text-muted">
            Create a review for revision v{revisionId} of this artifact.
          </p>
          <FormField
            label="Reviewer Persona"
            htmlFor="new-review-persona"
            helper="The persona performing the review."
          >
            <Input
              id="new-review-persona"
              inputSize="sm"
              value={reviewerPersona}
              onChange={(e) => setReviewerPersona(e.target.value)}
              placeholder="e.g. senior-engineer"
            />
          </FormField>
          {createError && (
            <p className="text-xs text-danger" role="alert">
              {createError}
            </p>
          )}
          <div className="flex items-center gap-2">
            <Button
              size="sm"
              onClick={handleStartReview}
              disabled={submitting || !reviewerPersona.trim()}
              loading={submitting}
            >
              {submitting ? "Creating..." : "Create Review"}
            </Button>
            <Button
              size="sm"
              variant="ghost"
              onClick={() => {
                setShowStartForm(false);
                setCreateError(null);
              }}
            >
              Cancel
            </Button>
          </div>
        </Card>
      )}

      {/* Review list */}
      {isLoading ? (
        <div className="space-y-3 animate-pulse">
          <div className="h-16 bg-surface-1 rounded" />
          <div className="h-16 bg-surface-1 rounded" />
        </div>
      ) : reviewList.length === 0 ? (
        <EmptyState
          icon={<ChatBubbleLeftRightIcon />}
          title="No reviews yet"
          description="Start a review to add inline comments and feedback on this artifact."
        />
      ) : (
        <div className="space-y-3">
          {reviewList.map((review) => (
            <ReviewCard
              key={review.review_id}
              review={review}
              onCommentAdded={refreshReviews}
              onCompleted={refreshReviews}
            />
          ))}
        </div>
      )}
    </div>
  );
}
