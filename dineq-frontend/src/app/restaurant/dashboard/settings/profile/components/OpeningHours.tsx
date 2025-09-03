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

const OpeningHours = () => {
  return (
    // The root div no longer needs any overflow or min-width classes.
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
        {/* THIS IS THE SCROLL CONTAINER FOR THE WEEKLY TABLE */}
        <div className="border border-gray-200 rounded-lg overflow-x-auto">
          {/* We add a min-width to the table content itself */}
          <div className="min-w-[600px]">
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
                        {/* SVG Icon */}
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
      </div>

      {/* Special Days */}
      <div>
        <h2 className="text-xl font-semibold text-gray-800 mb-2">
          Special days
        </h2>
        <p className="text-gray-600 mb-4 text-sm">
          Add holiday closures or happy hours.
        </p>
        {/* THIS IS THE SCROLL CONTAINER FOR THE SPECIAL DAYS TABLE */}
        <div className="border border-gray-200 rounded-lg overflow-x-auto">
          {/* We add a min-width to this table's content */}
          <div className="min-w-[700px]">
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
                    <button className="text-red-500 hover:text-red-700 ml-4 shrink-0">
                      {/* SVG Icon */}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Add Date Button */}
      <div className="mt-6">{/* ... button code ... */}</div>
    </div>
  );
};

export default OpeningHours;
