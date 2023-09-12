unit SciterEmbedded;

interface

uses
  Windows, Messages, Classes, Controls, SysUtils, Contnrs, Variants, Math, Graphics, Generics.Collections,
  SciterJS, SciterJSAPI;

type
  TSciterEmbedded = class(TCustomControl)
  private
    FSciter: TSciter;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function DesignMode: boolean;
    procedure Paint; override;
    procedure SetName(const NewName: TComponentName); override;
    procedure WndProc(var Message: TMessage); override;

    procedure OnDocumentComplete(ASender: TObject; const Args: TSciterOnDocumentCompleteEventArgs);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MouseWheelHandler(var Message: TMessage); override;

    property Sciter: TSciter read FSciter;
  published
    property Action;
    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderWidth;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default False;
    property Visible;
  end;

implementation

procedure TSciterEmbedded.OnDocumentComplete(ASender: TObject; const Args: TSciterOnDocumentCompleteEventArgs);
var
  bHandled: BOOL;
begin
  // Temporary fix: sometimes bottom part of document stays invisible until parent form gets resized
  API.SciterProcND(Handle, WM_SIZE, 0, MAKELPARAM(ClientRect.Right - ClientRect.Left, ClientRect.Bottom - ClientRect.Top), bHandled);
end;

constructor TSciterEmbedded.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetParentComponent(AOwner);
  Align := alClient;
  FSciter := TSciter.Create(Handle);
  FSciter.OnDocumentComplete := OnDocumentComplete;
end;

destructor TSciterEmbedded.Destroy;
begin
  FreeAndNil(FSciter);
  inherited;
end;

procedure TSciterEmbedded.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CHILD or WS_VISIBLE;
  if TabStop then
    Params.Style := Params.Style or WS_TABSTOP;
  Params.ExStyle := Params.ExStyle or WS_EX_CONTROLPARENT;
end;

function TSciterEmbedded.DesignMode: boolean;
begin
  Result := csDesigning in ComponentState;
end;

{ Tweaking TWinControl MouseWheel behavior }
procedure TSciterEmbedded.MouseWheelHandler(var Message: TMessage);
var
  pMsg: TWMMouseWheel;
begin
  pMsg := TWMMouseWheel(Message);
  if pMsg.WheelDelta < 0 then
    Perform(WM_VSCROLL, 1, 0)
  else
    Perform(WM_VSCROLL, 0, 0);
end;

procedure TSciterEmbedded.Paint;
var
  sCaption: String;
  iWidth: Integer;
  iHeight: Integer;
  X, Y: Integer;
  pIcon: TBitmap;
  hBmp: HBITMAP;
begin
  inherited;

  if DesignMode then
  begin
    sCaption := Name;

    pIcon := nil;

    hBMP := LoadBitmap(hInstance, 'TSCITER');
    if hBMP <> 0 then
    begin
      pIcon := TBitmap.Create;
      pIcon.Handle := hBMP;
    end;

    Canvas.Brush.Color := clWindow;
    iWidth := Canvas.TextWidth(sCaption) + 28;
    iHeight := Max(Canvas.TextHeight(sCaption), 28);
    X := Round(ClientWidth / 2) - Round(iWidth / 2);
    Y := Round(ClientHeight / 2) - Round(iHeight / 2);
    Canvas.FillRect(ClientRect);

    if pIcon <> nil then
      Canvas.Draw(X, Y, pIcon);

    Canvas.TextOut(X + 28, Y + 5, Name);

    if pIcon <> nil then
    begin
      pIcon.Free;
    end;

    if hBmp <> 0 then
      DeleteObject(hBmp);
  end;
end;

procedure TSciterEmbedded.SetName(const NewName: TComponentName);
begin
  inherited;
  if DesignMode then
    Invalidate;
end;

procedure TSciterEmbedded.WndProc(var Message: TMessage);
var
  llResult: LRESULT;
  bHandled: BOOL;
  M: PMsg;
begin
  if DesignMode then
  begin
    inherited WndProc(Message);
    Exit;
  end;

  case Message.Msg of
    WM_SETFOCUS:
      begin
        if Assigned(FSciter.OnFocus) then
          FSciter.OnFocus(Self);
      end;

    WM_GETDLGCODE:
      // Tweaking arrow keys and TAB handling (VCL-specific)
      begin
        Message.Result := DLGC_WANTALLKEYS or DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_HASSETSEL;
        if TabStop then
          Message.Result := Message.Result or DLGC_WANTTAB;
        if Message.lParam <> 0 then
        begin
          M := PMsg(Message.lParam);
          case M.Message of
            WM_SYSKEYDOWN, WM_SYSKEYUP, WM_SYSCHAR,
            WM_KEYDOWN, WM_KEYUP, WM_CHAR:
            begin
              Perform(M.message, M.wParam, M.lParam);
              // Message.Result := Message.Result or DLGC_WANTMESSAGE or DLGC_WANTTAB;
            end;
          end;
        end;
        Exit;
      end;
  end;

  bHandled := False;
  llResult := 0;
  if IsWindow(Handle) then
    llResult := API.SciterProcND(Handle, Message.Msg, Message.WParam, Message.LParam, bHandled);

  if bHandled then
    Message.Result := llResult
  else
    inherited WndProc(Message);
end;

end.
