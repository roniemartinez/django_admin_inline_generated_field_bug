from django.db import models
from django.db.models import F
from django.db.models.functions import Reverse


class Parent(models.Model):
    pass


class Example(models.Model):

    parent = models.ForeignKey(to="example.Parent", related_name="example", on_delete=models.PROTECT)
    name = models.CharField(max_length=100)
    reversed = models.GeneratedField(expression=Reverse(F("name")), output_field=models.CharField(max_length=100), db_persist=True)

    # This fixes the issue
    # def get_deferred_fields(self) -> set:
    #     deferred_field = super().get_deferred_fields()
    #     deferred_field.remove("reversed")
    #     return deferred_field