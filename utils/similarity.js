'use strict';

/**
 * Compute the Levenshtein distance between two strings.
 * @param {string} a
 * @param {string} b
 * @returns {number}
 */
function levenshtein(a, b) {
  const m = a.length;
  const n = b.length;

  // Create a (m+1) x (n+1) DP table using two rows for memory efficiency
  let prev = Array.from({ length: n + 1 }, (_, i) => i);
  let curr = new Array(n + 1);

  for (let i = 1; i <= m; i++) {
    curr[0] = i;
    for (let j = 1; j <= n; j++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      curr[j] = Math.min(
        prev[j]     + 1,          // deletion
        curr[j - 1] + 1,          // insertion
        prev[j - 1] + cost        // substitution
      );
    }
    [prev, curr] = [curr, prev];
  }

  return prev[n];
}

/**
 * Compute similarity score [0, 1] between two strings based on Levenshtein.
 * 1.0 = identical, 0.0 = completely different
 * @param {string} a
 * @param {string} b
 * @returns {number}
 */
function similarity(a, b) {
  if (!a && !b) return 1;
  if (!a || !b) return 0;

  const dist   = levenshtein(a, b);
  const maxLen = Math.max(a.length, b.length);
  return 1 - dist / maxLen;
}

/**
 * Normalize a string for matching:
 * - lowercase
 * - strip punctuation
 * - collapse whitespace
 * @param {string} text
 * @returns {string}
 */
function normalize(text) {
  return text
    .toLowerCase()
    .replace(/[^\w\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Compute word-overlap (Jaccard-like) similarity between two strings.
 * @param {string} a
 * @param {string} b
 * @returns {number}
 */
function wordOverlap(a, b) {
  const setA = new Set(a.split(' ').filter(Boolean));
  const setB = new Set(b.split(' ').filter(Boolean));

  if (!setA.size && !setB.size) return 1;
  if (!setA.size || !setB.size) return 0;

  const intersection = [...setA].filter(w => setB.has(w)).length;
  const union        = new Set([...setA, ...setB]).size;

  return intersection / union;
}

module.exports = { levenshtein, similarity, normalize, wordOverlap };
