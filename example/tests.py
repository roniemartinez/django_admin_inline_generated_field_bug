from django.test import TestCase

from example.models import Example


# Create your tests here.


class DuplicateTest(TestCase):

    def test_duplicate(self):
        example = Example(name="Ronie")
        example.save()

        self.assertEqual(example.reversed, "einoR")