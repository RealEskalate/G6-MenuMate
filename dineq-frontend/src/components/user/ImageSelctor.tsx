"use client";

import * as React from "react";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import {
  ToggleGroup,
  ToggleGroupItem,
} from "@/components/ui/toggle-group"; // from shadcn
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";

type Avatar = {
  id: number;
  url: string;
  gender: "male" | "female";
};

export default function AvatarSelector({
  avatars,
}: {
  avatars: Avatar[];
}) {
  const [gender, setGender] = React.useState<"male" | "female">("male");
  const [page, setPage] = React.useState(0); // each page = 10 avatars

  const filtered = avatars.filter((a) => a.gender === gender);
  const visible = filtered.slice(page * 10, page * 10 + 10);

  const handleMore = () => setPage((p) => p + 1);
  const handleBack = () => setPage((p) => p - 1);

  return (
    <Dialog open>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <DialogTitle>Select Avatar</DialogTitle>
        </DialogHeader>

        {/* Gender toggle (acts like radio) */}
        <ToggleGroup
          type="single"
          value={gender}
          onValueChange={(val) => {
            if (val === "male" || val === "female") {
              setGender(val);
              setPage(0); // reset paging when switching
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
        </ToggleGroup>

        {/* Avatar grid */}
        <div className="grid grid-cols-5 gap-3">
          {visible.map((avatar) => (
            <button
              key={avatar.id}
              className="rounded-full border-2 border-transparent hover:border-primary focus:border-primary"
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

        {/* Pagination buttons */}
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
      </DialogContent>
    </Dialog>
  );
}
