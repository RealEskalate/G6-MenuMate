interface HowToEatProps {
  steps: string[];
  tip: string;
}

interface ChefTipProps {
  chefName: string;
  message: string;
  audioUrl?: string;
}

interface FoodTipProps {
  howToEat: HowToEatProps;
  chefTip: ChefTipProps;
}

export default function FoodTip({ howToEat, chefTip }: FoodTipProps) {
  return (
    <div className=" border rounded-xl shadow-sm">
      {/* How to Eat Section */}
      <div className="p-4 ">
        <h2 className="text-2xl font-semibold mb-3">How to Eat Doro Wat</h2>
        <ol className="list-decimal list-inside space-y-1 text-gray-700">
          {howToEat.steps.map((step, index) => (
            <li key={index}>{step}</li>
          ))}
        </ol>
        <p className="text-sm italic text-gray-500 mt-2">{howToEat.tip}</p>
      </div>

      {/* Chef's Voice Tip Section */}
      <div className="p-4 ">
        <h2 className="text-2xl font-semibold mb-3">Chef&apos;s Voice Tip</h2>

        {/* Audio player placeholder */}
        <audio controls className="w-full">
          {chefTip.audioUrl && <source src={chefTip.audioUrl} type="audio/mpeg" />}
          Your browser does not support the audio element.
        </audio>

        <p className="text-sm text-gray-500 mt-2">
          This is a static prototype; audio functionality will be implemented later.
        </p>

        {/* Chef Note */}
        <div className="mt-3 bg-gray-50 p-3 rounded-lg border">
          <p className="font-semibold">
            {chefTip.chefName} says:
          </p>
          <p className="text-gray-700 mt-1">{chefTip.message}</p>
        </div>
      </div>
    </div>
  );
}
// interface FoodTipProps {
//   howToEat: string;
//   nutritional: {
//     calories: number;
//     protein: number;
//     carbs: number;
//     fat: number;
//   };
// }

// export default function FoodTip({ howToEat, nutritional }: FoodTipProps) {
//   return (
//     <div className="border rounded-xl shadow-sm p-4">
//       <h2 className="text-2xl font-semibold mb-3">How to Eat</h2>
//       <p className="text-gray-700 mb-4">{howToEat}</p>

//       <h2 className="text-2xl font-semibold mb-3">Nutritional Info</h2>
//       <ul className="text-gray-700 space-y-1">
//         <li>Calories: {nutritional.calories}</li>
//         <li>Protein: {nutritional.protein}g</li>
//         <li>Carbs: {nutritional.carbs}g</li>
//         <li>Fat: {nutritional.fat}g</li>
//       </ul>
//     </div>
//   );
// }
