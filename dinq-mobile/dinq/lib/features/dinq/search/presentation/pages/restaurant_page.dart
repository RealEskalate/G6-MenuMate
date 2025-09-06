// import 'package:flutter/material.dart';

// import '../../../../../core/util/theme.dart';

// import '../../../restaurant_management/domain/entities/item.dart';
// import '../../../restaurant_management/domain/entities/menu.dart';
// import '../../../restaurant_management/domain/entities/restaurant.dart';
// import '../widgets/bottom_navbar.dart';
// import 'item_details_page.dart';

// class _FavoritesStore {
//   static final Set<String> restaurantIds = <String>{};
//   // Removed unused dishIds
// }

// class RestaurantPage extends StatefulWidget {
//   final Restaurant restaurant;
//   final Menu menu;

//   const RestaurantPage({Key? key, required this.restaurant, required this.menu})
//       : super(key: key);

//   @override
//   State<RestaurantPage> createState() => _RestaurantPageState();
// }

// class _RestaurantPageState extends State<RestaurantPage>
//     with TickerProviderStateMixin {
//   // Removed TabController and tabs
//   static final Set<String> _favoriteRestaurantIds = {}; // For UI only
//   // Removed unused _favoriteRestaurantIds

//   @override
//   void initState() {
//     super.initState();
//   }

//   void _toggleFavorite() {
//     setState(() {
//       if (_FavoritesStore.restaurantIds.contains(widget.restaurant.id)) {
//         _FavoritesStore.restaurantIds.remove(widget.restaurant.id);
//       } else {
//         _FavoritesStore.restaurantIds.add(widget.restaurant.id);
//       }
//     });
//   }

//   void _onTabSelected(BottomNavTab tab) {
//     if (tab == BottomNavTab.explore) {
//       Navigator.pushReplacementNamed(context, '/explore');
//     } else if (tab == BottomNavTab.favorites) {
//       Navigator.pushReplacementNamed(
//         context,
//         '/favorites',
//         arguments: {
//           'allRestaurants': [widget.restaurant],
//           'allDishes': widget.menu.items,
//         },
//       );
//     } else if (tab == BottomNavTab.profile) {
//       Navigator.pushReplacementNamed(context, '/profile');
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show all menu items in a single scrollable list
//     final allMenuItems = widget.menu.items;
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildRestaurantHeader(),
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: allMenuItems.length,
//                 itemBuilder: (context, index) {
//                   return _buildMenuItem(allMenuItems[index]);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavBar(
//         selectedTab: BottomNavTab.explore,
//         onTabSelected: _onTabSelected,
//       ),
//     );
//   }

//   Widget _buildRestaurantHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Banner + overlays
//         SizedBox(
//           height: 260,
//           width: double.infinity,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               // Banner image
//               ClipRRect(
//                 child: Image.network(
//                   (() {
//                     final url = widget.restaurant.coverImage ?? '';
//                     return url.isNotEmpty
//                         ? url
//                         : 'https://via.placeholder.com/800x400';
//                   })(),
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) =>
//                       Container(color: Colors.grey[300]),
//                 ),
//               ),

//               // Bottom gradient for text readability
//               Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [Colors.black54, Colors.transparent],
//                   ),
//                 ),
//               ),

//               // Top actions (back / share)
//               SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8.0,
//                     vertical: 8.0,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _circleIcon(
//                         icon: Icons.arrow_back,
//                         onTap: () => Navigator.pop(context),
//                       ),
//                       _circleIcon(icon: Icons.share_outlined, onTap: () {}),
//                     ],
//                   ),
//                 ),
//               ),

//               // Name + subtitle (bottom-left)
//               Positioned(
//                 left: 16,
//                 bottom: 16,
//                 right: 16,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.restaurant.restaurantName,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         height: 1.2,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     if (widget.restaurant.about != null)
//                       Text(
//                         widget.restaurant.about!,
//                         style: const TextStyle(
//                             color: Colors.white70, fontSize: 14),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         // Floating info card overlapping the banner bottom
//         Transform.translate(
//           offset: const Offset(0, -20),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: _buildRestaurantInfoCard(),
//           ),
//         ),

//         const SizedBox(height: 4),

//         // Digital Menu row (kept as-is, just placed after the card)
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Digital Menu',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                 ),
//                 icon: const Icon(Icons.translate_rounded, color: Colors.white),
//                 onPressed: () {},
//                 label: const Text(
//                   'Translate',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 8),
//       ],
//     );
//   }

//   Widget _buildRestaurantInfoCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.orange, size: 16),
//                 SizedBox(width: 6),
//                 Expanded(child: Text('Bole Atlas, Addis Ababa')),
//               ],
//             ),
//             const SizedBox(height: 8),
//             const Row(
//               children: [
//                 Icon(Icons.access_time, color: Colors.orange, size: 16),
//                 SizedBox(width: 6),
//                 Expanded(child: Text('Open: 11:00 AM - 10:00 PM')),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 const Icon(Icons.star, color: Colors.orange, size: 16),
//                 const SizedBox(width: 4),
//                 const Text(
//                   '4.8',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(width: 6),
//                 const Text('(142 reviews)'),
//                 const Spacer(),
//                 OutlinedButton.icon(
//                   onPressed: _toggleFavorite,
//                   icon: const Icon(Icons.bookmark_border),
//                   label: const Text('Save'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.black,
//                     side: const BorderSide(color: Colors.black12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _circleIcon({required IconData icon, required VoidCallback onTap}) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(24),
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 6,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Icon(icon, color: Colors.black87),
//       ),
//     );
//   }

//   // Removed _buildTabBar

//   // Removed _buildTabContent

//   Widget _buildMenuItem(Item item) {
//     // Use the menu passed to this page for context (index/total)
//     final itemIndex = widget.menu.items.indexOf(item);
//     final totalItems = widget.menu.items.length;

//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(
//           context,
//           '/item-detail',
//           arguments: {'item': item},
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 4.0,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (item.images != null && item.images!.isNotEmpty)
//               ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   bottomLeft: Radius.circular(12),
//                 ),
//                 child: Image.network(
//                   item.images![0],
//                   width: 100,
//                   height: 100,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       width: 100,
//                       height: 100,
//                       color: Colors.grey[300],
//                       child: const Icon(Icons.restaurant, color: Colors.grey),
//                     );
//                   },
//                 ),
//               )
//             else
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     bottomLeft: Radius.circular(12),
//                   ),
//                 ),
//                 child: const Icon(Icons.restaurant, color: Colors.grey),
//               ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (itemIndex >= 0)
//                       Text(
//                         'Item ${itemIndex + 1} of $totalItems',
//                         style:
//                             const TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                     const SizedBox(height: 4),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             item.name,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '${item.price.toStringAsFixed(0)} ${item.currency}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.primaryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (item.description != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         item.description!,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
