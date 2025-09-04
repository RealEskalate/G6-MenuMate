// components/MapModal.tsx
import React, { useState, useEffect } from "react";
import { MapContainer, TileLayer, Marker, useMapEvents } from "react-leaflet";
import L from "leaflet";

// Fix for default marker icon issue with Webpack
delete (L.Icon.Default.prototype as any)._get  ;

L.Icon.Default.mergeOptions({
  iconRetinaUrl:
    "https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png",
  iconUrl: "https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png",
  shadowUrl: "https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png",
});

type MapModalProps = {
  isOpen: boolean;
  onClose: () => void;
  onSelectLocation: (location: { lat: number; lng: number }) => void;
  initialLocation?: { lat: number; lng: number };
};

const DEFAULT_MAP_CENTER: L.LatLngExpression = [0, 0]; // Default if no initial location
const DEFAULT_MAP_ZOOM = 2; // World view
const DETAILED_MAP_ZOOM = 13; // Closer view for specific location

function LocationMarker({
  onLocationChange,
  initialPosition,
}: {
  onLocationChange: (latlng: L.LatLng) => void;
  initialPosition?: { lat: number; lng: number };
}) {
  const [position, setPosition] = useState<L.LatLng | null>(
    initialPosition ? L.latLng(initialPosition.lat, initialPosition.lng) : null
  );

  const map = useMapEvents({
    click(e) {
      setPosition(e.latlng);
      onLocationChange(e.latlng);
    },
    // Listen for when map becomes ready to center it initially
    load() {
        if (initialPosition && !position) { // Only set if map loaded and no current position
            const latlng = L.latLng(initialPosition.lat, initialPosition.lng);
            setPosition(latlng);
            map.setView(latlng, DETAILED_MAP_ZOOM);
        }
    }
  });

  // Re-center map if initialPosition changes
  useEffect(() => {
    if (initialPosition) {
      const latlng = L.latLng(initialPosition.lat, initialPosition.lng);
      setPosition(latlng); // Update marker position
      map.setView(latlng, DETAILED_MAP_ZOOM); // Set view with detailed zoom
    }
  }, [initialPosition, map]);


  return position === null ? null : <Marker position={position}></Marker>;
}

export default function MapModal({
  isOpen,
  onClose,
  onSelectLocation,
  initialLocation,
}: MapModalProps) {
  const [selectedPosition, setSelectedPosition] = useState<L.LatLng | null>(
    initialLocation ? L.latLng(initialLocation.lat, initialLocation.lng) : null
  );

  // Set initial selectedPosition when modal opens or initialLocation changes
  useEffect(() => {
    if (isOpen && initialLocation) {
      setSelectedPosition(L.latLng(initialLocation.lat, initialLocation.lng));
    } else if (!isOpen) {
      setSelectedPosition(null); // Clear selected position when modal closes
    }
  }, [isOpen, initialLocation]);

  const handleLocationChange = (latlng: L.LatLng) => {
    setSelectedPosition(latlng);
  };

  const handleSave = () => {
    if (selectedPosition) {
      onSelectLocation({
        lat: selectedPosition.lat,
        lng: selectedPosition.lng,
      });
    }
    onClose();
  };

  if (!isOpen) return null;

  // Determine the map's initial center and zoom
  const mapCenter: L.LatLngExpression = initialLocation
    ? [initialLocation.lat, initialLocation.lng]
    : DEFAULT_MAP_CENTER;
  const mapZoom = initialLocation ? DETAILED_MAP_ZOOM : DEFAULT_MAP_ZOOM;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Blurred background overlay - apply backdrop-blur to this div */}
      <div
        className="absolute inset-0 bg-black bg-opacity-50 backdrop-filter backdrop-blur-sm"
        onClick={onClose}
      ></div>

      {/* Modal content */}
      <div className="relative bg-white rounded-lg shadow-xl p-4 w-11/12 md:w-2/3 lg:w-1/2 h-3/4 flex flex-col z-50">
        <h3 className="text-xl font-semibold mb-3">Select Location on Map</h3>
        <div className="flex-grow rounded-md overflow-hidden">
          <MapContainer
            center={mapCenter}
            zoom={mapZoom}
            scrollWheelZoom={true}
            className="h-full w-full"
            key={JSON.stringify(mapCenter)} // Key to force remount when center changes
          >
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            <LocationMarker
              onLocationChange={handleLocationChange}
              initialPosition={selectedPosition || initialLocation} // Pass selected or initial
            />
          </MapContainer>
        </div>
        <div className="flex justify-end mt-4 space-x-2">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={handleSave}
            disabled={!selectedPosition}
            className="px-4 py-2 bg-orange-500 text-white rounded-md hover:bg-orange-600 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Save Location
          </button>
        </div>
      </div>
    </div>
  );
}