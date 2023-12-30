from django.contrib import admin

from example.models import Example, Parent


class ExampleInline(admin.StackedInline):
    model = Example
    extra = 1


@admin.register(Parent)
class ExampleAdmin(admin.ModelAdmin):
    inlines = [ExampleInline]
