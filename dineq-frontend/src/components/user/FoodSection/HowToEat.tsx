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
    <div className="space-y-8 mt-6">
      {/* How to Eat Section */}
      <div className="p-4 border rounded-xl shadow-sm">
        <h2 className="text-2xl font-semibold mb-3">How to Eat Doro Wat</h2>
        <ol className="list-decimal list-inside space-y-1 text-gray-700">
          {howToEat.steps.map((step, index) => (
            <li key={index}>{step}</li>
          ))}
        </ol>
        <p className="text-sm italic text-gray-500 mt-2">{howToEat.tip}</p>
      </div>

      {/* Chef's Voice Tip Section */}
      <div className="p-4 border rounded-xl shadow-sm">
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
