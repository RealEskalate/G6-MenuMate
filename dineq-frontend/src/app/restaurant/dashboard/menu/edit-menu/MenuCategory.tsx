import MenuItemCard from "./MenuItemCard";

interface MenuItem {
  id: string,
  title: string;
  description: string;
  price: number;
  image: string;
}

export default function MenuCategory({
  title,
  items,
}: {
  title?: string;
  items: MenuItem[];
}) {
  return (
    <div>
      {title && <h4 className="font-semibold mb-3">{title}</h4>}
      <div className="grid md:grid-cols-2 gap-4">
        {items.map((item, idx) => (
          <MenuItemCard key={idx} {...item} />
        ))}
      </div>
    </div>
  );
}
