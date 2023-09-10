////
////  PetListView.swift
////  keepers
////
////  Created by Hung on 9/5/23.
////
//
//import SwiftUI
//import SwiftData
//
//struct PetListView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var pets: [Pet_Identity]
//
//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(pets) { pet in
//                    NavigationLink {
//                        Text("Pet (\(pet.name)) at \(pet.birthDate, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                        Text("mind: \(pet.personality.mind), nature: \(pet.personality.nature), energy: \(pet.personality.energy)")
//                    } label: {
//                        Text(pet.birthDate, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deletePets)
//            }
//#if os(macOS)
//            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
//#endif
//            .toolbar {
//#if os(iOS)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//#endif
//                ToolbarItem {
//                    Button(action: addPet) {
//                        Label("Add Pet", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select a pet")
//        }
//    }
//
//    private func addPet() {
//        withAnimation {
//            let newPet = Pet_Identity(name: "Pet #\(Int.random(in: 0..<100))", 
//                                      personality: Pet_Personality(
//                                        mind: Int8.random(in: Int8.min...Int8.max),
//                                        nature: Int8.random(in: Int8.min...Int8.max),
//                                        energy: Int8.random(in: Int8.min...Int8.max)),
//                                      birthDate: Date())
//            modelContext.insert(newPet)
//        }
//    }
//
//    private func deletePets(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(pets[index])
//            }
//        }
//    }
//}
//
//#Preview {
//    PetListView()
//        .modelContainer(for: Pet_Identity.self, inMemory: true)
//}
