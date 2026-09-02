"use client";

import { useState } from "react";
import { Button } from "./button";
import { Dialog, DialogContent } from "./dialog";

export function useConfirm() {
  const [state, setState] = useState<{
    open: boolean;
    title: string;
    description?: string;
    confirmLabel: string;
    danger?: boolean;
    resolve?: (v: boolean) => void;
  }>({ open: false, title: "", confirmLabel: "Confirm" });

  const confirm = (opts: {
    title: string;
    description?: string;
    confirmLabel?: string;
    danger?: boolean;
  }) =>
    new Promise<boolean>((resolve) => {
      setState({
        open: true,
        title: opts.title,
        description: opts.description,
        confirmLabel: opts.confirmLabel ?? "Confirm",
        danger: opts.danger,
        resolve,
      });
    });

  const node = (
    <Dialog
      open={state.open}
      onOpenChange={(open) => {
        if (!open) {
          state.resolve?.(false);
          setState((s) => ({ ...s, open: false }));
        }
      }}
    >
      <DialogContent title={state.title} description={state.description}>
        <div className="flex justify-end gap-2 pt-2">
          <Button
            variant="secondary"
            onClick={() => {
              state.resolve?.(false);
              setState((s) => ({ ...s, open: false }));
            }}
          >
            Cancel
          </Button>
          <Button
            variant={state.danger ? "danger" : "primary"}
            onClick={() => {
              state.resolve?.(true);
              setState((s) => ({ ...s, open: false }));
            }}
          >
            {state.confirmLabel}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );

  return { confirm, confirmDialog: node };
}
