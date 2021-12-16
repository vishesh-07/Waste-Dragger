enum wasteTypes { dry, wet, ewaste }

class Waste {
  late final String imageURL;
  late final wasteTypes wt;
  Waste({required this.imageURL, required this.wt});
}

var wasteProductList = [
  Waste(imageURL: 'assets/dry1.png', wt: wasteTypes.dry),
  Waste(imageURL: 'assets/dry2.png', wt: wasteTypes.dry),
  Waste(imageURL: 'assets/dry3.png', wt: wasteTypes.dry),
  Waste(imageURL: 'assets/dry4.png', wt: wasteTypes.dry),
  Waste(imageURL: 'assets/wet1.png', wt: wasteTypes.wet),
  Waste(imageURL: 'assets/wet2.png', wt: wasteTypes.wet),
  Waste(imageURL: 'assets/e1.png', wt: wasteTypes.ewaste),
  Waste(imageURL: 'assets/e2.png', wt: wasteTypes.ewaste),
  Waste(imageURL: 'assets/e3.png', wt: wasteTypes.ewaste),
  Waste(imageURL: 'assets/e5.png', wt: wasteTypes.ewaste),
];
