type ToggleSwitchProps = {
  checked: boolean;
};

// A reusable Toggle Switch component
const ToggleSwitch = ({ checked }: ToggleSwitchProps) => (
  <label className="relative inline-flex items-center cursor-pointer">
    <input
      type="checkbox"
      value=""
      className="sr-only peer"
      defaultChecked={checked}
    />
    <div className="w-11 h-6 bg-gray-200 rounded-full peer peer-focus:ring-2 peer-focus:ring-orange-300 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-0.5 after:left-[2px] after:bg-white after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-orange-500"></div>
  </label>
);

// Data for the weekly schedule
const weekDays = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];

// Data for the special days schedule
const specialDaysData = [
  {
    day: "Sep 10,2018",
    event: "Ethiopian New Year",
    status: "Closed" as const,
  },
  {
    day: "Sep 09,2018",
    event: "Ethiopian New Year Eve",
    status: "Open" as const,
    open: "03:00am",
    close: "01:00pm",
  },
];

// The new component for Opening and Closing Hours
const OpeningHours = () => {
  return (
    <div className="mt-10">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-800">
          Opening and Closing Hours
        </h1>
        <p className="text-gray-600 mt-1">
          Set your opening and closing hours so that customers know when you're
          open.
        </p>
      </div>

      {/* Weekly Schedule */}
      <div className="mb-12">
        <h2 className="text-xl font-semibold text-gray-800 mb-4">
          Weekly Schedule
        </h2>
        <div className="border border-gray-200 rounded-lg overflow-hidden">
          {/* Table Header */}
          <div className="grid grid-cols-5 items-center bg-gray-50 text-left text-sm font-medium text-gray-500 px-4 py-3">
            <div className="col-span-2">Day</div>
            <div>open</div>
            <div className="col-span-2">Shift (opening - closing)</div>
          </div>
          {/* Table Body */}
          <div>
            {weekDays.map((day) => (
              <div
                key={day}
                className="grid grid-cols-5 items-center px-4 py-3 border-t border-gray-200"
              >
                <div className="col-span-2 flex items-center text-sm text-gray-700 font-medium">
                  {day}
                  {day === "Monday" && (
                    <button className="ml-2 text-gray-400 hover:text-gray-600">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-4 w-4"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        strokeWidth="2"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
                        />
                      </svg>
                    </button>
                  )}
                </div>
                <div>
                  <ToggleSwitch checked={true} />
                </div>
                <div className="col-span-2 flex items-center gap-2">
                  <div className="text-sm text-center w-24 border border-gray-300 rounded-md px-3 py-1.5 bg-gray-50 text-gray-700">
                    03:00am
                  </div>
                  <div className="text-sm text-center w-24 border border-gray-300 rounded-md px-3 py-1.5 bg-gray-50 text-gray-700">
                    01:00pm
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Special Days */}
      <div>
        <h2 className="text-xl font-semibold text-gray-800 mb-2">
          Special days
        </h2>
        <p className="text-gray-600 mb-4 text-sm">
          Add holiday closures or happy hours.
        </p>
        <div className="border border-gray-200 rounded-lg overflow-hidden">
          {/* Table Header */}
          <div className="grid grid-cols-6 items-center bg-gray-50 text-left text-sm font-medium text-gray-500 px-4 py-3">
            <div className="col-span-2">Day</div>
            <div className="col-span-2">Event</div>
            <div className="col-span-2">happy hour or closed</div>
          </div>
          {/* Table Body */}
          <div>
            {specialDaysData.map((item, index) => (
              <div
                key={index}
                className="grid grid-cols-6 items-center px-4 py-4 border-t border-gray-200"
              >
                <div className="col-span-2 text-sm text-gray-700 font-medium">
                  {item.day}
                </div>
                <div className="col-span-2 text-sm text-gray-700">
                  {item.event}
                </div>
                <div className="col-span-2 flex items-center justify-between">
                  {item.status === "Closed" ? (
                    <span className="text-sm text-gray-700">Closed</span>
                  ) : (
                    <div className="flex items-center gap-2">
                      <div className="text-sm text-center w-24 border border-gray-300 rounded-md px-3 py-1.5 bg-gray-50 text-gray-700">
                        {item.open}
                      </div>
                      <div className="text-sm text-center w-24 border border-gray-300 rounded-md px-3 py-1.5 bg-gray-50 text-gray-700">
                        {item.close}
                      </div>
                    </div>
                  )}
                  <button className="text-red-500 hover:text-red-700 ml-4">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      className="h-5 w-5"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                      strokeWidth="2"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                      />
                    </svg>
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Add Date Button */}
      <div className="mt-6">
        <button className="flex items-center gap-2 px-4 py-2 border border-orange-400 text-orange-500 font-semibold rounded-lg hover:bg-orange-50 transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-5 w-5"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            strokeWidth="2"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M12 4v16m8-8H4"
            />
          </svg>
          Add date
        </button>
      </div>
    </div>
  );
};

export default OpeningHours;

// END: Helper components for the Opening Hours section
