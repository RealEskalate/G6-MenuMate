"use client";

import * as React from "react";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group";
import { Input } from "@/components/ui/input"; // Import Input component
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";

type Avatar = {
  id: number;
  url: string;
  gender: "male" | "female";
};

type AvatarSelectorProps = {
  avatars: Avatar[];
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSelect: (url: string) => void;
  onSelectLocalFile: (file: File) => void;
};

export default function AvatarSelector({
  avatars,
  open,
  onOpenChange,
  onSelect,
  onSelectLocalFile,
}: AvatarSelectorProps) {
  const [selectionType, setSelectionType] = React.useState<"male" | "female" | "local">("male");
  const [page, setPage] = React.useState(0);

  // Filter avatars based on gender selection
  const filtered = avatars.filter((a) => a.gender === selectionType);
  const visible = filtered.slice(page * 10, page * 10 + 10);

  const handleMore = () => setPage((p) => p + 1);
  const handleBack = () => setPage((p) => p - 1);

  // Handle file selection from local storage
  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      onSelectLocalFile(file);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <DialogTitle>Select Avatar</DialogTitle>
        </DialogHeader>

        {/* Updated ToggleGroup for Male, Female, and Local upload */}
        <ToggleGroup
          type="single"
          value={selectionType}
          onValueChange={(val) => {
            if (val === "male" || val === "female" || val === "local") {
              setSelectionType(val);
              setPage(0);
            }
          }}
          className="flex gap-2 mb-4"
        >
          <ToggleGroupItem value="male" className="px-4 py-2">
            Male
          </ToggleGroupItem>
          <ToggleGroupItem value="female" className="px-4 py-2">
            Female
          </ToggleGroupItem>
          <ToggleGroupItem value="local" className="px-4 py-2">
            Upload from Local
          </ToggleGroupItem>
        </ToggleGroup>

        {/* Conditionally render based on selectionType */}
        {selectionType === 'local' ? (
          <div className="flex flex-col items-center justify-center p-8 border-2 border-dashed rounded-lg">
            <p className="text-gray-500 mb-4 text-center">
              Please select an image file from your device.
            </p>
            <Input
              type="file"
              accept="image/*"
              onChange={handleFileChange}
              className="w-full"
            />
          </div>
        ) : (
          <>
            <div className="grid grid-cols-5 gap-3">
              {visible.map((avatar) => (
                <button
                  key={avatar.id}
                  onClick={() => onSelect(avatar.url)}
                  className="rounded-full border-2 border-transparent hover:border-primary focus:border-primary transition-all duration-200"
                >
                  <Image
                    src={avatar.url}
                    alt={`Avatar ${avatar.id}`}
                    width={64}
                    height={64}
                    className="rounded-full"
                  />
                </button>
              ))}
            </div>

            <div className="flex justify-between mt-4">
              <Button onClick={handleBack} disabled={page === 0}>
                Go Back
              </Button>
              <Button
                onClick={handleMore}
                disabled={(page + 1) * 10 >= filtered.length}
              >
                More
              </Button>
            </div>
          </>
        )}
      </DialogContent>
    </Dialog>
  );
}