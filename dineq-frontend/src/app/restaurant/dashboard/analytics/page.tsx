"use client"; // Required for the recharts library

import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import {
  Eye,
  QrCode,
  Star,
  Download,
  MoreVertical,
  Calendar,
} from "lucide-react";
import React from "react";

// --- Data for Components ---

const overviewStats = [
  {
    icon: <Eye className="text-orange-500" />,
    title: "Total Menu View",
    value: "1,245",
  },
  {
    icon: <QrCode className="text-orange-500" />,
    title: "Total QR Scans",
    value: "400",
  },
  {
    icon: <Star className="text-orange-500" />,
    title: "Average Rating",
    value: "4.8",
  },
];

const visitorsData = [
  { name: "6AM", visitors: 150 },
  { name: "8AM", visitors: 250 },
  { name: "10AM", visitors: 350 },
  { name: "12PM", visitors: 500 },
  { name: "2PM", visitors: 650 },
  { name: "4PM", visitors: 800 },
  { name: "6PM", visitors: 850 },
  { name: "8PM", visitors: 700 },
  { name: "10PM", visitors: 400 },
];

const popularItemsData = [
  { name: "Special Firfir", views: 245 },
  { name: "Shawarma", views: 198 },
  { name: "Combo", views: 156 },
  { name: "Lasagna", views: 142 },
  { name: "Caprese Salad", views: 115 },
];

const reviewsChartData = [
  { stars: 5, count: 60 },
  { stars: 4, count: 80 },
  { stars: 3, count: 50 },
  { stars: 2, count: 120 },
  { stars: 1, count: 30 },
];

const recentReviewsData = [
  {
    name: "Alex J.",
    dish: "Derek Tibs",
    rating: 4,
    comment: "Portion could be bigger ...",
    date: "Aug 12",
  },
  {
    name: "Alex J.",
    dish: "Derek Tibs",
    rating: 4,
    comment: "Portion could be bigger ...",
    date: "Aug 12",
  },
  {
    name: "Alex J.",
    dish: "Derek Tibs",
    rating: 4,
    comment: "Portion could be bigger ...",
    date: "Aug 12",
  },
  {
    name: "Alex J.",
    dish: "Derek Tibs",
    rating: 4,
    comment: "Portion could be bigger ...",
    date: "Aug 12",
  },
  {
    name: "Alex J.",
    dish: "Derek Tibs",
    rating: 4,
    comment: "Portion could be bigger ...",
    date: "Aug 12",
  },
];

const allReviewsData = [
  {
    reviewer: "Alex J.",
    dish: "Doro Wat",
    rating: 4,
    preview: "Portion could be bigger ...",
  },
  {
    reviewer: "Alex J.",
    dish: "Firfir",
    rating: 4,
    preview: "Portion could be bigger ...",
  },
  {
    reviewer: "Alex J.",
    dish: "Shiro",
    rating: 3,
    preview: "Portion could be bigger ...",
  },
  {
    reviewer: "Alex J.",
    dish: "Doro Wat",
    rating: 5,
    preview: "Portion could be bigger ...",
  },
  {
    reviewer: "Alex J.",
    dish: "Doro Wat",
    rating: 4,
    preview: "Portion could be bigger ...",
  },
  {
    reviewer: "Alex J.",
    dish: "Doro Wat",
    rating: 4,
    preview: "Portion could be bigger ...",
  },
];

// --- Reusable Card Component ---

const Card = ({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) => (
  <div className={`bg-white p-6 rounded-lg shadow-sm ${className}`}>
    {children}
  </div>
);

// --- Main Page Component ---

export default function AnalyticsPage() {
  const maxPopularViews = Math.max(
    ...popularItemsData.map((item) => item.views)
  );
  const maxReviewCount = Math.max(...reviewsChartData.map((r) => r.count));

  return (
    <div className="space-y-8">
      {/* Header */}
      <header>
        <h1 className="text-4xl font-bold">Analytics</h1>
      </header>

      {/* Time Filter Buttons */}
      <div className="flex flex-wrap gap-2">
        <button className="bg-orange-500 text-white px-4 py-2 rounded-lg text-sm font-semibold">
          Today
        </button>
        <button className="bg-white text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold border hover:border-gray-400">
          Week
        </button>
        <button className="bg-white text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold border hover:border-gray-400">
          Month
        </button>
        <button className="bg-white text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold border hover:border-gray-400">
          Year
        </button>
        <button className="bg-white text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold border hover:border-gray-400 flex items-center">
          <Calendar size={16} className="mr-2" />
          Custom
        </button>
      </div>

      {/* Analytics Overview Section */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {overviewStats.map((stat, index) => (
          <Card key={index} className="flex items-center space-x-4">
            <div className="bg-orange-100 p-3 rounded-full">{stat.icon}</div>
            <div>
              <p className="text-gray-500 text-sm">{stat.title}</p>
              <p className="text-2xl font-bold">{stat.value}</p>
            </div>
          </Card>
        ))}
      </div>

      {/* Charts and Lists Section */}
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-8">
        {/* Visitors by Time of Day */}
        <Card>
          <div className="flex justify-between items-center mb-4">
            <h3 className="font-bold text-lg">Visitors by Time of Day</h3>
            <div className="flex items-center space-x-2">
              <button className="text-gray-500 hover:text-gray-800">
                <Download size={20} />
              </button>
              <button className="text-gray-500 hover:text-gray-800">
                <MoreVertical size={20} />
              </button>
            </div>
          </div>
          <div style={{ width: "100%", height: 300 }}>
            <ResponsiveContainer>
              <BarChart
                data={visitorsData}
                margin={{ top: 5, right: 20, left: -10, bottom: 5 }}
              >
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="name" tickLine={false} axisLine={false} />
                <YAxis tickLine={false} axisLine={false} />
                <Tooltip
                  cursor={{ fill: "rgba(249, 115, 22, 0.1)" }}
                  contentStyle={{
                    background: "#fff",
                    border: "1px solid #ddd",
                    borderRadius: "0.5rem",
                  }}
                />
                <Bar
                  dataKey="visitors"
                  fill="#F97316"
                  radius={[4, 4, 0, 0]}
                  barSize={30}
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Popular Menu Items */}
        <Card>
          <div className="flex justify-between items-center mb-4">
            <h3 className="font-bold text-lg">Popular Menu Items</h3>
            <div className="flex items-center space-x-2">
              <button className="text-gray-500 hover:text-gray-800">
                <Download size={20} />
              </button>
              <button className="text-gray-500 hover:text-gray-800">
                <MoreVertical size={20} />
              </button>
            </div>
          </div>
          <div className="space-y-4">
            {popularItemsData.map((item, index) => (
              <div key={index}>
                <div className="flex justify-between items-center mb-1">
                  <p className="font-medium">{item.name}</p>
                  <p className="text-sm text-gray-500">{item.views} views</p>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-orange-500 h-2 rounded-full"
                    style={{
                      width: `${(item.views / maxPopularViews) * 100}%`,
                    }}
                  ></div>
                </div>
              </div>
            ))}
          </div>
        </Card>

        {/* Reviews Chart */}
        <Card>
          <h3 className="font-bold text-lg mb-4">Reviews</h3>
          <div className="space-y-3">
            {reviewsChartData.map((review) => (
              <div key={review.stars} className="flex items-center space-x-4">
                <div className="flex items-center text-sm text-gray-500">
                  <span>{review.stars}</span>
                  <Star
                    size={16}
                    className="ml-1 text-yellow-400 fill-current"
                  />
                </div>
                <div className="flex-grow bg-gray-200 rounded-full h-4">
                  <div
                    className="bg-orange-500 h-4 rounded-full"
                    style={{
                      width: `${(review.count / maxReviewCount) * 100}%`,
                    }}
                  ></div>
                </div>
                <div className="text-sm font-medium w-8 text-right">
                  {review.count}
                </div>
              </div>
            ))}
          </div>
        </Card>

        {/* Recent Reviews List */}
        <Card>
          <h3 className="font-bold text-lg mb-4">Recent Reviews (latest 5)</h3>
          <div className="space-y-4">
            {recentReviewsData.map((review, index) => (
              <div key={index} className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-gray-200 rounded-full"></div>
                  <div>
                    <p className="font-semibold text-sm md:text-base">
                      {review.name} • {review.rating}
                      <Star
                        size={14}
                        className="inline-block mb-1 ml-1 text-yellow-400 fill-current"
                      />{" "}
                      • {review.dish}
                    </p>
                    <p className="text-sm text-gray-500">{review.comment}</p>
                  </div>
                </div>
                <p className="text-sm text-gray-400 flex-shrink-0 ml-2">
                  {review.date}
                </p>
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* All Reviews Table */}
      <Card>
        <h3 className="font-bold text-lg mb-4">All Reviews</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b">
                <th className="py-2 font-medium text-gray-500">Reviewer</th>
                <th className="py-2 font-medium text-gray-500">Dish</th>
                <th className="py-2 font-medium text-gray-500">Rating</th>
                <th className="py-2 font-medium text-gray-500">Preview</th>
              </tr>
            </thead>
            <tbody>
              {allReviewsData.map((review, index) => (
                <tr key={index} className="border-b last:border-b-0">
                  <td className="py-4 flex items-center space-x-3">
                    <div className="w-8 h-8 bg-gray-200 rounded-full flex-shrink-0"></div>
                    <span className="whitespace-nowrap">{review.reviewer}</span>
                  </td>
                  <td className="py-4">{review.dish}</td>
                  <td className="py-4">
                    <div className="flex items-center whitespace-nowrap">
                      {review.rating}{" "}
                      <Star
                        size={16}
                        className="ml-1 text-yellow-400 fill-current"
                      />
                    </div>
                  </td>
                  <td className="py-4 text-gray-500">{review.preview}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
