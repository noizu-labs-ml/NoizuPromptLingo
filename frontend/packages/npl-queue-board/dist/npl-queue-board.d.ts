import { LitElement, type PropertyValues } from 'lit';
import type { QueueDataProvider } from './types.js';
export declare class NplQueueBoard extends LitElement {
    static styles: import("lit").CSSResult[];
    dataProvider: QueueDataProvider | null;
    boardId: string;
    heading: string;
    theme: 'auto' | 'light' | 'dark';
    hideEmptyStages: boolean;
    private _loading;
    private _error;
    private _data;
    private _loadSeq;
    private _abort;
    refresh(): Promise<void>;
    protected willUpdate(changed: PropertyValues<this>): void;
    private _load;
    private _activate;
    render(): import("lit-html").TemplateResult<1>;
    private _renderLoading;
    private _renderError;
    private _renderBoards;
    private _renderBoard;
    private _renderColumn;
    private _renderCard;
}
declare global {
    interface HTMLElementTagNameMap {
        'npl-queue-board': NplQueueBoard;
    }
}
