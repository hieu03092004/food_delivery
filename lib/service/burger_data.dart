import 'package:food_delivery/model/burger_model.dart';

List<BurgerModel> getBurger() {
  List<BurgerModel> burger = [];
  BurgerModel burgerModel = new BurgerModel();
  burgerModel.name = "Cheese Burger";
  burgerModel.image = "images/burger1.png";
  burgerModel.price = "50";

  burger.add(burgerModel);
  burgerModel = new BurgerModel();
  burgerModel.name = "Veggie Burger";
  burgerModel.image = "images/burger2.png";
  burgerModel.price = "50";

  burger.add(burgerModel);
  burgerModel = new BurgerModel();
  burgerModel.name = "Veggie Burger";
  burgerModel.image = "images/burger2.png";
  burgerModel.price = "50";

  burger.add(burgerModel);
  burgerModel = new BurgerModel();
  burgerModel.name = "Veggie Burger";
  burgerModel.image = "images/burger2.png";
  burgerModel.price = "50";

  burger.add(burgerModel);
  return burger;
}