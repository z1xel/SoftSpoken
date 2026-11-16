"""Synthetic tests for source text difference classification; no third-party prose."""
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
import analyze_turtle_conflicting_dialogue as review


class TestDialogueComparison(unittest.TestCase):
    def test_punctuation_is_not_a_rewrite(self):
        row = review.compare_text("Hello, traveler!", "Hello traveler.")
        self.assertEqual(row["edit_category"], "punctuation_or_whitespace")

    def test_missing_substantial_text_is_flagged(self):
        row = review.compare_text(
            "An ancient dragon calls from the mountain.",
            "The document has been delivered to the harbor. Twelve miners await.")
        self.assertEqual(row["edit_category"], "substantial_difference")

    def test_game_placeholders_checked_independently(self):
        row = review.compare_text(
            "Thank you $N. $B Come here.", "Thank you $C. Come here.")
        self.assertEqual(row["variable_tokens_changed"], 1)
        self.assertIn("$N", row["spoken_tokens"])
        self.assertIn("$C", row["turtle_tokens"])

    def test_wow_directive_lexer_stops_at_one_character(self):
        self.assertEqual(review.variables("$BHello, $n! $gking:queen;"),
                         ["$B", "$n", "$g"])
        row = review.compare_text("$bHello $n!", "$BHello $N!")
        self.assertEqual(row["directive_case_only"], 1)
        self.assertEqual(row["directive_sequence_changed"], 0)
        changed = review.compare_text("Thank you $N", "Thank you $C")
        self.assertEqual(changed["directive_sequence_changed"], 1)

    def test_same_text_is_not_conflict(self):
        with self.assertRaisesRegex(ValueError, "two different"):
            review.compare_text("The same text.", "The same text.")

    def test_short_excerpt_focuses_on_changed_words(self):
        a, b = review.first_changed_excerpt(
            "Quest begins in the forest with two goblins.",
            "Quest begins in the forest with three trolls.")
        self.assertIn("goblins", a)
        self.assertIn("trolls", b)


if __name__ == "__main__":
    unittest.main()
