from django.db import models
from django.utils import timezone

from location.models import Location
from user.models import Vendor, Customer, User


# Create your product models here.


class ProductList(models.Model):
    name = models.CharField(max_length=255)
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE)
    is_private = models.BooleanField(default=True)  # private can only seen by owner
    is_alert_list = models.BooleanField(default=False)  # True if it is an alert list

    def __str__(self):
        return self.customer.user.username + " - " + self.name


def productImage(instance, filename):
    return '/'.join(['images', str(instance.name), filename])


# Category has a parent in the same table, De Facto rule is that parent of a parent will always be the id=1
class Category(models.Model):
    name = models.CharField(max_length=255, unique=True)
    parent = models.ForeignKey("self", default=0, on_delete=models.CASCADE, db_constraint=False)

    def __str__(self):
        return self.name


class Product(models.Model):
    name = models.CharField(max_length=255)
    detail = models.CharField(max_length=1023, blank=True)
    brand = models.CharField(max_length=255)
    price = models.FloatField()
    stock = models.IntegerField(default=0)
    rating = models.FloatField(default=0)
    sell_counter = models.IntegerField(default=0)
    release_date = models.DateTimeField(default=timezone.now)
    picture = models.ImageField(upload_to=productImage, null=True, blank=True, default=None)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, default=1)

    vendor = models.ForeignKey(
        Vendor,
        on_delete=models.CASCADE,
        related_name="products"
    )

    in_lists = models.ManyToManyField(ProductList, blank=True)

    def __str__(self):
        return self.name + " " + self.vendor.user.username


# SubOrder is equivalent to a Product in a Customer(User)'s Cart
class SubOrder(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE)
    amount = models.IntegerField(default=0)
    purchased = models.BooleanField(default=False)


class Label(models.Model):
    name = models.CharField(max_length=255, unique=True)
    products = models.ManyToManyField(Product, related_name="labels", blank=True)

    def __str__(self):
        return self.name


class Order(models.Model):
    
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE)
    timestamp = models.DateTimeField(auto_now_add=True, blank=True)
    #sub_order = models.ForeignKey(SubOrder, on_delete=models.CASCADE)
    
class Delivery(models.Model):
    STATUS_TYPES = (
        (1, "Preparing"),
        (2, "On the Way"),
        (3, "Delivered"),
        (4, "Cancelled"),
    )
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    timestamp = models.DateTimeField(auto_now_add=True, blank=True)
    delivery_time = models.DateTimeField(blank=True)
    current_status = models.PositiveSmallIntegerField(choices=STATUS_TYPES, default=1)
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE)
    amount = models.IntegerField(default=0)
    location = models.ForeignKey(Location,on_delete=models.CASCADE, blank=True)
class Comment(models.Model):
    RATES = (
        (1, "Awful"),
        (2, "Bad"),
        (3, "Mediocre"),
        (4, "Good"),
        (5, "Excellent"),
    )
    timestamp = models.DateTimeField(auto_now_add=True)
    body = models.CharField(max_length=255)
    rating = models.PositiveSmallIntegerField(choices=RATES, default=5)
    is_anonymous = models.BooleanField(default=False)
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)


class Payment(models.Model):
    owner = models.ForeignKey(Customer, on_delete=models.CASCADE)
    # Below are cart info, TODO encrypt them
    name_on_card = models.CharField(max_length=255)
    card_name = models.CharField(max_length=255)
    card_id = models.CharField(max_length=16)
    date_month = models.CharField(max_length=2)
    date_year = models.CharField(max_length=2)
    cvv = models.CharField(max_length=3)


class SearchHistory(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    searched = models.CharField(max_length=255, default="")
