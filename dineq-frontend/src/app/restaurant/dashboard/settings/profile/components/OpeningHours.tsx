"use client";

import React, { useState } from "react";

// === TYPE DEFINITIONS TO MATCH THE API ===
export type DaySchedule = {
  day: string;
  is_open: boolean;
  start_time?: string;
  end_time?: string;
};

export type SpecialDay = {
  date: string;
  is_open: boolean;
  event: string;
  start_time?: string;
  end_time?: string;
};

// === PROPS INTERFACE ===
type OpeningHoursProps = {
  schedule: DaySchedule[];
  specialDays: SpecialDay[];
  onScheduleChange: (
    day: string,
    field: "is_open" | "start_time" | "end_time",
    value: any
  ) => void;
  onSpecialDayAdd: (newDay: SpecialDay) => void;
  onSpecialDayDelete: (date: string) => void;
};

const DeleteIcon = () => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="red"
    viewBox="0 0 24 24"
    stroke="currentColor"
    className="w-6 h-6"
  >
    <path
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={2}
      d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 
           01-1.995-1.858L5 7m5 4v6m4-6v6M1 7h22M9 7V4a1 1 0 
           011-1h4a1 1 0 011 1v3"
    />
  </svg>
);

// A reusable Toggle Switch component (now accepts onChange)
const ToggleSwitch = ({
  checked,
  onChange,
}: {
  checked: boolean;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}) => (
  <label className="relative inline-flex items-center cursor-pointer">
    <input
      type="checkbox"
      checked={checked}
      onChange={onChange}
      className="sr-only peer"
    />
    <div className="w-11 h-6 bg-gray-200 rounded-full peer peer-focus:ring-2 peer-focus:ring-orange-300 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-0.5 after:left-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-orange-500"></div>
  </label>
);

const OpeningHours = ({
  schedule,
  specialDays,
  onScheduleChange,
  onSpecialDayAdd,
  onSpecialDayDelete,
}: OpeningHoursProps) => {
  const [newSpecialDay, setNewSpecialDay] = useState<SpecialDay>({
    date: "",
    event: "",
    is_open: true,
    start_time: "09:00",
    end_time: "17:00",
  });

  const handleAddNewSpecialDay = () => {
    if (!newSpecialDay.date || !newSpecialDay.event) {
      alert("Please provide a date and event name for the special day.");
      return;
    }
    onSpecialDayAdd(newSpecialDay);
    setNewSpecialDay({
      date: "",
      event: "",
      is_open: true,
      start_time: "00:00",
      end_time: "00:00",
    });
  };

  return (
    <div className="mt-10">
      <h2 className="text-2xl font-bold text-gray-800 mb-1">
        Opening and Closing Hours
      </h2>
      <p className="text-gray-600 mb-8">
        Set your opening and closing hours so that customers know when you're
        open.
      </p>

      {/* Weekly Schedule */}
      <div className="mb-12">
        <h3 className="text-xl font-semibold text-gray-800 mb-4">
          Weekly Schedule
        </h3>
        <div className="border border-gray-200 rounded-lg overflow-x-auto">
          <div className="min-w-[600px]">
            <div className="grid grid-cols-5 items-center bg-gray-50 text-left text-sm font-medium text-gray-500 px-4 py-3">
              <div className="col-span-2">Day</div>
              <div>Open</div>
              <div className="col-span-2">Shift (opening - closing)</div>
            </div>
            <div>
              {schedule.map((daySchedule) => (
                <div
                  key={daySchedule.day}
                  className="grid grid-cols-5 items-center px-4 py-3 border-t"
                >
                  <div className="col-span-2 font-medium text-gray-700 capitalize">
                    {daySchedule.day}
                  </div>
                  <div>
                    <ToggleSwitch
                      checked={daySchedule.is_open}
                      onChange={() =>
                        onScheduleChange(
                          daySchedule.day,
                          "is_open",
                          !daySchedule.is_open
                        )
                      }
                    />
                  </div>
                  <div className="col-span-2 flex items-center gap-2">
                    <input
                      type="time"
                      defaultValue={daySchedule.start_time || ""}
                      onBlur={(e) =>
                        onScheduleChange(
                          daySchedule.day,
                          "start_time",
                          e.target.value
                        )
                      }
                      disabled={!daySchedule.is_open}
                      className="w-28 border-gray-300 rounded-md p-1.5 text-sm disabled:bg-gray-100"
                    />
                    <input
                      type="time"
                      defaultValue={daySchedule.end_time || ""}
                      onBlur={(e) =>
                        onScheduleChange(
                          daySchedule.day,
                          "end_time",
                          e.target.value
                        )
                      }
                      disabled={!daySchedule.is_open}
                      className="w-28 border-gray-300 rounded-md p-1.5 text-sm disabled:bg-gray-100"
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Special Days */}
      <div>
        <h3 className="text-xl font-semibold text-gray-800 mb-2">
          Special Days
        </h3>
        <p className="text-gray-600 mb-4 text-sm">
          Add holiday closures or happy hours.
        </p>
        <div className="border border-gray-200 rounded-lg overflow-x-auto">
          <div className="min-w-[700px]">
            <div className="grid grid-cols-7 items-center bg-gray-50 text-left text-sm font-medium text-gray-500 px-4 py-3">
              <div className="col-span-2">Day</div>
              <div className="col-span-2">Event</div>
              <div className="col-span-3">Happy hour or closed</div>
            </div>
            <div>
              {specialDays.map((item) => (
                <div
                  key={item.date}
                  className="grid grid-cols-7 items-center px-4 py-4 border-t"
                >
                  <div className="col-span-2 text-sm text-gray-700 font-medium">
                    {item.date}
                  </div>
                  <div className="col-span-2 text-sm text-gray-700">
                    {item.event}
                  </div>
                  <div className="col-span-3 flex items-center justify-between">
                    {!item.is_open ? (
                      <span>Closed</span>
                    ) : (
                      <div className="flex items-center gap-2">
                        <span className="text-sm">
                          {item.start_time} - {item.end_time}
                        </span>
                      </div>
                    )}
                    <button
                      onClick={() => onSpecialDayDelete(item.date)}
                      className="text-red-500 hover:text-red-700 ml-4 shrink-0"
                    >
                      <DeleteIcon />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
        <div className="mt-4 p-4 border rounded-lg bg-gray-50 flex flex-wrap items-end gap-4">
          <input
            type="date"
            value={newSpecialDay.date}
            onChange={(e) =>
              setNewSpecialDay((p) => ({ ...p, date: e.target.value }))
            }
            className="border-gray-300 rounded-md p-1.5 text-sm"
          />
          <input
            type="text"
            placeholder="Event Name"
            value={newSpecialDay.event}
            onChange={(e) =>
              setNewSpecialDay((p) => ({ ...p, event: e.target.value }))
            }
            className="border-gray-300 rounded-md p-1.5 text-sm"
          />
          <ToggleSwitch
            checked={newSpecialDay.is_open}
            onChange={() =>
              setNewSpecialDay((p) => ({ ...p, is_open: !p.is_open }))
            }
          />
          {newSpecialDay.is_open && (
            <>
              <input
                type="time"
                value={newSpecialDay.start_time}
                onChange={(e) =>
                  setNewSpecialDay((p) => ({
                    ...p,
                    start_time: e.target.value,
                  }))
                }
                className="border-gray-300 rounded-md p-1.5 text-sm"
              />
              <input
                type="time"
                value={newSpecialDay.end_time}
                onChange={(e) =>
                  setNewSpecialDay((p) => ({ ...p, end_time: e.target.value }))
                }
                className="border-gray-300 rounded-md p-1.5 text-sm"
              />
            </>
          )}
          <button
            onClick={handleAddNewSpecialDay}
            className="bg-orange-500 text-white px-4 py-1.5 rounded-lg text-sm font-semibold hover:bg-orange-600"
          >
            Add Date
          </button>
        </div>
      </div>
    </div>
  );
};

export default OpeningHours;
