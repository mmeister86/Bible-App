//
//  VerseCategory.swift
//  Bible App
//

import Foundation

/// A curated category of Bible verses grouped by mood or life situation.
struct VerseCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let accentColorHex: String
    let verseReferences: [String]
}

extension VerseCategory {
    static let allCategories: [VerseCategory] = [
        VerseCategory(
            id: "comfort",
            name: "Comfort",
            icon: "heart.circle.fill",
            description: "When you need reassurance",
            accentColorHex: "#E88D67",
            verseReferences: [
                "Psalm 23:4",
                "Psalm 34:18",
                "Isaiah 41:10",
                "Isaiah 43:2",
                "Matthew 5:4",
                "Matthew 11:28-30",
                "2 Corinthians 1:3-4",
                "Romans 8:28",
                "Psalm 147:3",
                "Revelation 21:4"
            ]
        ),
        VerseCategory(
            id: "peace",
            name: "Peace",
            icon: "leaf.fill",
            description: "For a calm and quiet spirit",
            accentColorHex: "#7FB685",
            verseReferences: [
                "John 14:27",
                "Philippians 4:6-7",
                "Isaiah 26:3",
                "Psalm 46:10",
                "Colossians 3:15",
                "Romans 15:13",
                "Numbers 6:24-26",
                "Psalm 4:8",
                "Isaiah 32:17",
                "2 Thessalonians 3:16"
            ]
        ),
        VerseCategory(
            id: "hope",
            name: "Hope",
            icon: "sunrise.fill",
            description: "Light in difficult times",
            accentColorHex: "#F2C94C",
            verseReferences: [
                "Jeremiah 29:11",
                "Romans 15:13",
                "Romans 8:24-25",
                "Hebrews 11:1",
                "Psalm 42:11",
                "Lamentations 3:22-23",
                "Isaiah 40:31",
                "Psalm 130:5",
                "1 Peter 1:3",
                "Romans 5:3-5"
            ]
        ),
        VerseCategory(
            id: "courage",
            name: "Courage",
            icon: "shield.fill",
            description: "Strength to face your fears",
            accentColorHex: "#5B8DEF",
            verseReferences: [
                "Joshua 1:9",
                "Deuteronomy 31:6",
                "Isaiah 41:13",
                "Psalm 27:1",
                "2 Timothy 1:7",
                "Isaiah 43:1",
                "Psalm 56:3-4",
                "Proverbs 28:1",
                "1 Corinthians 16:13",
                "Ephesians 6:10"
            ]
        ),
        VerseCategory(
            id: "love",
            name: "Love",
            icon: "heart.fill",
            description: "God's unconditional love",
            accentColorHex: "#E06C75",
            verseReferences: [
                "1 Corinthians 13:4-7",
                "John 3:16",
                "Romans 8:38-39",
                "1 John 4:7-8",
                "1 John 4:19",
                "Ephesians 3:17-19",
                "Psalm 136:1",
                "Zephaniah 3:17",
                "John 15:12-13",
                "Romans 5:8"
            ]
        ),
        VerseCategory(
            id: "strength",
            name: "Strength",
            icon: "figure.stand",
            description: "When you feel overwhelmed",
            accentColorHex: "#C78BDA",
            verseReferences: [
                "Philippians 4:13",
                "Isaiah 40:29",
                "Psalm 73:26",
                "2 Corinthians 12:9-10",
                "Nehemiah 8:10",
                "Psalm 18:32",
                "Ephesians 3:16",
                "Psalm 28:7",
                "Isaiah 41:10",
                "Habakkuk 3:19"
            ]
        ),
        VerseCategory(
            id: "anxiety",
            name: "Anxiety & Fear",
            icon: "cloud.sun.fill",
            description: "Release your worries",
            accentColorHex: "#6AC1C5",
            verseReferences: [
                "1 Peter 5:7",
                "Philippians 4:6-7",
                "Matthew 6:25-27",
                "Psalm 55:22",
                "Isaiah 41:10",
                "Psalm 94:19",
                "Matthew 6:34",
                "Deuteronomy 31:8",
                "Psalm 23:4",
                "Luke 12:25-26"
            ]
        ),
        VerseCategory(
            id: "gratitude",
            name: "Gratitude",
            icon: "hands.sparkles.fill",
            description: "Cultivate a thankful heart",
            accentColorHex: "#F2994A",
            verseReferences: [
                "1 Thessalonians 5:18",
                "Psalm 107:1",
                "Colossians 3:17",
                "Psalm 100:4-5",
                "Psalm 136:1",
                "James 1:17",
                "Philippians 4:4-6",
                "Psalm 9:1",
                "Ephesians 5:20",
                "Psalm 118:24"
            ]
        ),
        VerseCategory(
            id: "wisdom",
            name: "Wisdom",
            icon: "book.closed.fill",
            description: "Guidance for life's decisions",
            accentColorHex: "#BD8C5E",
            verseReferences: [
                "Proverbs 3:5-6",
                "James 1:5",
                "Proverbs 2:6",
                "Psalm 111:10",
                "Proverbs 4:7",
                "Colossians 2:2-3",
                "Proverbs 16:16",
                "Ecclesiastes 7:12",
                "Proverbs 9:10",
                "Psalm 119:105"
            ]
        ),
        VerseCategory(
            id: "forgiveness",
            name: "Forgiveness",
            icon: "arrow.uturn.backward.circle.fill",
            description: "Grace and new beginnings",
            accentColorHex: "#9B8EC7",
            verseReferences: [
                "1 John 1:9",
                "Ephesians 4:32",
                "Colossians 3:13",
                "Psalm 103:12",
                "Isaiah 1:18",
                "Micah 7:18-19",
                "Acts 3:19",
                "Matthew 6:14-15",
                "Psalm 32:5",
                "2 Chronicles 7:14"
            ]
        )
    ]
}
