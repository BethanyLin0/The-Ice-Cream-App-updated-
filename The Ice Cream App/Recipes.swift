//
//  Recipes.swift
//  Ice Cream
//
//  Created by Bethany on 2025/3/5.
//
import SwiftUI
import SwiftData

// MARK: - MAIN GALLERY VIEW
struct Recipes: View {
    // @Query retrieves all Recipes from database and then sorts them according to "dateCreated" (ordered from new to old)
    @Query(sort: \Recipe.dateCreated, order: .reverse) private var allRecipes: [Recipe]
    @Environment(\.modelContext) private var context
    
    // This controls when the "Add a Recipe" sheet appears. It's hidden at first.
    @State private var showSheet = false
    
    // When a recipe needs to be edited
    @State private var recipeToEdit: Recipe?
    
    // Tracks search input for the Mac-style search bar
    @State private var searchText = ""
    
    // This defines a "Lazy Grid" that automatically fits as many cards as possible in a row based on window width.
    let columns = [
        GridItem(.adaptive(minimum: 280, maximum: 400), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Header Area
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Frances' Lab")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text("Recipes Gallery")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                    }
                    
                    Spacer()
                    
                    // Mac-style Search & Action
                    HStack(spacing: 15) {
                        TextField("Search...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 180)
                        
                        // A button for adding new recipes (by calling out the AddRecipeView sheet)
                        Button {
                            showSheet = true
                        } label: {
                            Label("New Recipe", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.04, green: 0.43, blue: 0.25))
                    }
                }
                .padding(.bottom, 10)
                
                Divider()
                
                // ForEach turns an array of data into multiple views, now displayed in a Grid instead of a List
                if filteredRecipes.isEmpty {
                    ContentUnavailableView("No Recipes Found", systemImage: "book.closed")
                        .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(filteredRecipes) { recipe in
                            RecipeCardView(recipe: recipe)
                            // When this card is tapped/clicked, the edit recipe sheet shows up
                                .onTapGesture {
                                    recipeToEdit = recipe
                                }
                            // Allows Mac users to Right-Click a card to delete it
                                .contextMenu {
                                    Button(role: .destructive) {
                                        context.delete(recipe)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .padding(40)
        }
        .background(Color(NSColor.windowBackgroundColor))
        // This sheet is used to add new recipes
        .sheet(isPresented: $showSheet) {
            AddRecipeView()
                .frame(minWidth: 500, minHeight: 450)
        }
        // This EditRecipeSheet is called when a card is tapped/clicked
        .sheet(item: $recipeToEdit) { recipe in
            EditRecipeSheet(recipe: recipe)
                .frame(minWidth: 500, minHeight: 450)
        }
    }
    
    // computed property to filter recipes in real-time as the user types
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty { return allRecipes }
        return allRecipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - RECIPE CARD SUBVIEW
struct RecipeCardView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.72, green: 0.9, blue: 0.66).opacity(0.2))
                    .frame(height: 120)
                
                Image(systemName: "flanders.icecream.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(red: 0.04, green: 0.43, blue: 0.25))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Ingredients: \(recipe.ingredients)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Divider()
            
            HStack {
                // Formats the Date into a readable string (e.g., "Mar 5, 2025")
                Text("Last Made: \(recipe.lastMade.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let url = URL(string: recipe.tutorialLink), !recipe.tutorialLink.isEmpty {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Text("Tutorial")
                            Image(systemName: "arrow.up.right.square")
                        }
                        .font(.caption.bold())
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: - ADD RECIPE VIEW
struct AddRecipeView: View {
    // Get SwiftData's Context (used to input new data)
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // State variables store the data and track changes
    @State private var name = ""
    @State private var ingredients = ""
    @State private var lastMade = Date()
    @State private var tutorialLink = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            // Creates organized sections for user input
            Form {
                Section("Basics") {
                    TextField("Name 🍦", text: $name)
                    TextField("Ingredients 🥛", text: $ingredients)
                }
                Section("Details") {
                    DatePicker("Last Made ⏰", selection: $lastMade, displayedComponents: .date)
                    TextField("Tutorial Link 🔗", text: $tutorialLink)
                }
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .formStyle(.grouped) // Adds the Mac-style inset background
            .navigationTitle("Add a Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { addRecipe() }
                        .disabled(name.isEmpty) // Only save if name is not empty
                }
            }
        }
    }
    
    // This function saves the inputted data for new recipe
    func addRecipe() {
        let newRecipe = Recipe(name: name, ingredients: ingredients, lastMade: lastMade, tutorialLink: tutorialLink, notes: notes)
        context.insert(newRecipe)
        dismiss()
    }
}

// MARK: - EDIT RECIPE SHEET
struct EditRecipeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var recipe: Recipe // Bindable allows changes to sync automatically to SwiftData
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name 🍦") { TextField("Name", text: $recipe.name) }
                Section("Ingredients 🥛") { TextField("Ingredients", text: $recipe.ingredients) }
                Section("Details") {
                    DatePicker("Last Made ⏰", selection: $recipe.lastMade, displayedComponents: .date)
                    TextField("Tutorial Link 🔗", text: $recipe.tutorialLink)
                }
                Section("Notes 📝") {
                    TextEditor(text: $recipe.notes)
                        .frame(minHeight: 100)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Recipe")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}

#Preview {
    Recipes()
}
