import Image from "next/image";
import Link from "next/link";

interface MenuOptionModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function MenuOptionModal({ isOpen, onClose }: MenuOptionModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm">
      <div className="bg-white rounded-2xl p-8 shadow-xl max-w-lg w-full text-center">
        <h2 className="text-xl font-bold mb-8">
          How do you want to create your menu?
        </h2>

        <div className="flex justify-center gap-10">
          {/* OCR Option */}
          <Link href="/restaurant/dashboard/menu/ocr_menu" className="group">
            <div className="w-40 h-40 border border-orange-300 rounded-xl flex flex-col items-center justify-center gap-3 hover:shadow-lg hover:border-orange-500 transition">
              <Image
                src="/icons/scan_ocr.jpg"
                alt="Scan OCR"
                width={24}
                height={24}
                className="w-12 h-12 text-orange-500"
              />
              <p className="text-sm font-medium">Scan with OCR</p>
            </div>
          </Link>

          {/* Manual Option */}
          <Link href="/restaurant/dashboard/menu/manual_menu" className="group">
            <div className="w-40 h-40 border border-orange-300 rounded-xl flex flex-col items-center justify-center gap-3 hover:shadow-[0_4px_12px_#ffead4] hover:border-orange-500 transition">
              <Image
                src="/icons/create_manually.png"
                alt="Create manually"
                width={24}
                height={24}
                className="w-12 h-12 text-orange-500"
              />
              <p className="text-sm font-medium">Create manually</p>
            </div>
          </Link>
        </div>

        {/* Close button */}
        <button
          onClick={onClose}
          className="mt-6 text-sm font-bold text-black-500 hover:text-orange-700"
        >
          Cancel
        </button>
      </div>
    </div>
  );
}
