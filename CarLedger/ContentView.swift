//
//  ContentView.swift
//  CarLedger
//
//  Created by Dev Reptech on 04/03/2024.


import SwiftUI



struct FuelEntry: Identifiable {
    let id = UUID()
    var date: Date
    var carModel: String // Adding car model name property
    var fuelQuantity: Double
    var cost: Double
}

struct Car: Identifiable {
    let id = UUID()
    var model: String
    var mileage: Int
    var oilChangeDate: Date
    var tireCondition: String
    // Add more properties for additional maintenance records
}

class CarViewModel: ObservableObject {
    @Published var cars: [Car] = []

    func addCar(car: Car) {
        cars.append(car)
    }
}


struct ContentView: View {
    @ObservedObject var carViewModel = CarViewModel()
    @ObservedObject var fuelTracker = FuelTracker()
    @FocusState private var isFocused: Bool
    @State private var model = ""
    @State private var mileage = ""
    @State private var oilChangeDate = Date()
    @State private var tireCondition = ""
    @State private var carModelName = ""

    var body: some View {
        ZStack {
            VStack {
                TabView {
                    NavigationView {
                        VStack {
                            CarListView(carViewModel: carViewModel, model: $model, mileage: $mileage, oilChangeDate: $oilChangeDate, tireCondition: $tireCondition)
                                .navigationBarTitle("My Cars")
                            Spacer()
                        }
                    }
                    .tabItem {
                        Image(systemName: "car")
                        Text("Cars")
                    }

                    NavigationView {
                        FuelTrackerView(fuelTracker: fuelTracker)
                            .navigationBarTitle("Fuel Consumption Tracker")
                    }
                    .tabItem {
                        Image(systemName: "flame")
                        Text("Fuel Tracker")
                    }

                    NavigationView {
                        FuelExpensesView(fuelTracker: fuelTracker)
                            .navigationBarTitle("Fuel Expenses")
                    }
                    .tabItem {
                        Image(systemName: "dollarsign.circle")
                        Text("Fuel Expenses")
                    }
                }
            }
            .padding(.bottom, 8) // Adjust padding if needed

            // Tap gesture to dismiss keyboard
            Color.clear
                .onTapGesture {
                    // Dismiss keyboard when tapping around the app
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        }
    }
}

struct CarListView: View {
    @ObservedObject var carViewModel: CarViewModel
    @Binding var model: String
    @Binding var mileage: String
    @Binding var oilChangeDate: Date
    @Binding var tireCondition: String
    @FocusState private var isFocused: Bool
    @State private var showAlert = false

    var body: some View {
        List {
            Section(header: Text("Add Car Details")) {
                TextField("Model", text: $model)
                    .focused($isFocused)
                    .submitLabel(.done)
                
                TextField("Mileage", text: $mileage)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                    .padding(.horizontal)
                            }
                    }
                
                DatePicker("Oil Change Date", selection: $oilChangeDate, displayedComponents: .date)
                    .focused($isFocused)
                
                TextField("Tire Condition", text: $tireCondition)
                    .focused($isFocused)
                    .submitLabel(.done)
            }

            Section {
                Button(action: addCar) {
                    Text("Add Car")
                        .foregroundColor(.blue)
                }
            }

            ForEach(carViewModel.cars) { car in
                NavigationLink(destination: CarDetailView(car: car, carViewModel: carViewModel)) {
                    Text(car.model)
                }
            }
            .onDelete(perform: deleteCar)
        }
        .navigationBarItems(trailing: Button(action: {
            showAlert = true
        }) {
            Image(systemName: "plus")
        })
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Add Car"), message: Text(""), dismissButton: .default(Text("OK")))
        }
    }

    func addCar() {
        guard let mileage = Int(mileage) else { return }
        let newCar = Car(model: model, mileage: mileage, oilChangeDate: oilChangeDate, tireCondition: tireCondition)
        carViewModel.addCar(car: newCar)

        // Reset input fields after adding the car
        model = ""
        self.mileage = ""
        oilChangeDate = Date()
        tireCondition = ""
        showAlert = false
    }

    func deleteCar(at offsets: IndexSet) {
        carViewModel.cars.remove(atOffsets: offsets)
    }
}




struct CarDetailView: View {
    var car: Car
    @ObservedObject var carViewModel: CarViewModel
    var body: some View {
        VStack {
            Text("Car Model: \(car.model)")
            Text("Mileage: \(car.mileage)")
            Text("Last Oil Change Date: \(formattedDate(date: car.oilChangeDate))")
            Text("Tire Condition: \(car.tireCondition)")
            NavigationLink(destination: EditCarView(carViewModel: carViewModel, car: car)) {
                Text("Edit")
            }
            // Add more views for other maintenance records
        }
        .navigationBarTitle(car.model)
    }

    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct AddCarView: View {
    @ObservedObject var carViewModel: CarViewModel
    @State private var model = ""
    @State private var mileage = ""
    @State private var oilChangeDate = Date()
    @State private var tireCondition = ""
    @State private var showAlert = false
    @FocusState private var keyboardFocused: Bool
    var body: some View {
        Form {
            Section(header: Text("Car Details")) {
                TextField("Model", text: $model)
                    .submitLabel(.done)
                TextField("Mileage", text: $mileage)
                    .keyboardType(.numberPad)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                    .padding(.horizontal)
                            }
                    }
                DatePicker("Oil Change Date", selection: $oilChangeDate, displayedComponents: .date)
                   
                TextField("Tire Condition", text: $tireCondition)
                    .submitLabel(.done)
                // Add more input fields for other maintenance records
            }
            Button(action: addCar) {
                Text("Add Car")
                    .foregroundColor(.blue)
            }
            
        }
        .navigationBarTitle("Add Car")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Success"), message: Text("Car added successfully"), dismissButton: .default(Text("OK")))
        }
    }

    func addCar() {
        guard let mileage = Int(mileage) else { return }
        let newCar = Car(model: model, mileage: mileage, oilChangeDate: oilChangeDate, tireCondition: tireCondition)
        carViewModel.addCar(car: newCar)
        // Reset input fields after adding the car
        model = ""
        self.mileage = ""
        oilChangeDate = Date()
        tireCondition = ""
        showAlert = true // Show alert after adding the car
    }
}

struct EditCarView: View {
    @ObservedObject var carViewModel: CarViewModel
    @State var car: Car

    var body: some View {
        Form {
            Section(header: Text("Car Details")) {
                TextField("Model", text: $car.model)
                    .submitLabel(.done)
                TextField("Mileage", value: $car.mileage, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .toolbar {
                            ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                DatePicker("Oil Change Date", selection: $car.oilChangeDate,
                           displayedComponents: .date)
               
                TextField("Tire Condition", text: $car.tireCondition)
                    .submitLabel(.done)
                // Add more input fields for other maintenance records
            }

            Button(action: updateCar) {
                Text("Save Changes")
            }
           
        }
        .navigationBarTitle("Edit Car")
    }

    func updateCar() {
        if let index = carViewModel.cars.firstIndex(where: { $0.id == car.id }) {
            carViewModel.cars[index] = car
        }
    }
}



class FuelTracker: ObservableObject {
    @Published var fuelEntries: [FuelEntry] = []
    
    // Function to add fuel entry with car model name
    func addFuelEntry(entry: FuelEntry, carModel: String) {
        var entryWithModel = entry
        entryWithModel.carModel = carModel // Assigning car model name
        fuelEntries.append(entryWithModel)
    }
}


struct FuelTrackerView: View {
    @ObservedObject var fuelTracker: FuelTracker
    @State private var selectedUnitIndex = 0
    @State private var odometerReading = ""
    @State private var fuelQuantity = ""
    @State private var cost = ""
    @State private var fuelPrice = ""
    @State private var carModelName = ""
    @State private var isEditing = false
    @State private var selectedEntry: FuelEntry?
    let units = ["Miles per Gallon", "Kilometers per Liter"]
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Fuel Entry Details")) {
                    TextField("Car Model", text: $carModelName)
                       
                    Picker("Select Unit", selection: $selectedUnitIndex) {
                        ForEach(0..<units.count) { index in
                            Text(units[index]).tag(index)
                               
                        }
                    }
                    
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("Odometer Reading", text: $odometerReading)
                        .keyboardType(.numberPad)
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }
                                        .padding(.horizontal)
                                }
                        }
                    
                    TextField("Fuel Quantity", text: $fuelQuantity)
                        .submitLabel(.done)
                        .keyboardType(.decimalPad)
                    
                    TextField("Fuel Price", text: $fuelPrice)
                        .submitLabel(.done)
                        .keyboardType(.decimalPad)
           
                    HStack { // Combine Add Fuel Entry button and Cost TextField
                        TextField("Cost", text: $cost)
                            .keyboardType(.decimalPad)
                            .submitLabel(.done)
                        Button(action: addFuelEntry) {
                            Text("Add Fuel Entry")
                        }
                    }
                 
                }
            }
            
            if fuelTracker.fuelEntries.isEmpty {
                Text("No fuel entries added yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(fuelTracker.fuelEntries) { entry in
                        FuelEntryRow(entry: entry, mileageUnit: units[selectedUnitIndex])
                    }
                    .onDelete(perform: deleteFuelEntry) // Move onDelete to List
                }
            }
            

        }
        .navigationBarTitle("Fuel Average Tracker")
        .sheet(isPresented: $isEditing, onDismiss: {
            // Handle any actions after dismissing the EditFuelEntryView
        }) {
            if let selectedEntry = selectedEntry {
                EditFuelEntryView(fuelTracker: fuelTracker, entry: selectedEntry, isPresented:  $isEditing)
            }
        }
    }
    
    func addFuelEntry() {
        guard let odometerReading = Double(odometerReading),
              let fuelQuantity = Double(fuelQuantity),
              let cost = Double(cost),
              let fuelPrice = Double(fuelPrice) else { return }
        
        guard !carModelName.isEmpty else {
            // Show alert or error message indicating missing fields
            return
        }
        
        let newEntry = FuelEntry(date: Date(), carModel: carModelName, fuelQuantity: fuelQuantity, cost: cost)
        fuelTracker.addFuelEntry(entry: newEntry, carModel: carModelName)
        
        self.odometerReading = ""
        self.fuelQuantity = ""
        self.cost = ""
        self.fuelPrice = ""
        self.carModelName = ""
    }
    
    func deleteFuelEntry(at offsets: IndexSet) {
        fuelTracker.fuelEntries.remove(atOffsets: offsets)
    }
}



//struct FuelTrackerView: View {
//    @ObservedObject var fuelTracker: FuelTracker
//    @State private var selectedUnitIndex = 0
//    @State private var odometerReading = ""
//    @State private var fuelQuantity = ""
//    @State private var cost = ""
//    @State private var fuelPrice = ""
//    @State private var carModelName = ""
//    @State private var isEditing = false
//    @State private var selectedEntry: FuelEntry?
//    let units = ["Miles per Gallon", "Kilometers per Liter"]
//    
//    var body: some View {
//        VStack {
//            Form {
//                Section(header: Text("Fuel Entry Details")) {
//                    TextField("Car Model", text: $carModelName)
//                       
//                    Picker("Select Unit", selection: $selectedUnitIndex) {
//                        ForEach(0..<units.count) { index in
//                            Text(units[index]).tag(index)
//                               
//                        }
//                    }
//                    
//                    .pickerStyle(SegmentedPickerStyle())
//                    
//                    TextField("Odometer Reading", text: $odometerReading)
//                        .keyboardType(.numberPad)
//                    
//                    TextField("Fuel Quantity", text: $fuelQuantity)
//                        .keyboardType(.decimalPad)
//                    
//                    TextField("Fuel Price", text: $fuelPrice)
//                        .keyboardType(.decimalPad)
//                    
//                    HStack { // Combine Add Fuel Entry button and Cost TextField
//                        TextField("Cost", text: $cost)
//                            .keyboardType(.decimalPad)
//                        Button(action: addFuelEntry) {
//                            Text("Add Fuel Entry")
//                        }
//                    }
//                }
//            }
//            
//            List {
//                ForEach(fuelTracker.fuelEntries) { entry in
//                    FuelEntryRow(entry: entry, mileageUnit: units[selectedUnitIndex])
//                }
//                .onDelete(perform: deleteFuelEntry) // Move onDelete to List
//            }
//        }.onTapGesture {
//            self.hideKeyboard()
//          }
//        .navigationBarTitle("Fuel Average Tracker")
//        .sheet(isPresented: $isEditing, onDismiss: {
//            // Handle any actions after dismissing the EditFuelEntryView
//        }) {
//            if let selectedEntry = selectedEntry {
//                EditFuelEntryView(fuelTracker: fuelTracker, entry: selectedEntry, isPresented:  $isEditing)
//            }
//        }
//    }
//    
//    func addFuelEntry() {
//        guard let odometerReading = Double(odometerReading),
//              let fuelQuantity = Double(fuelQuantity),
//              let cost = Double(cost),
//              let fuelPrice = Double(fuelPrice) else { return }
//        
//        guard !carModelName.isEmpty else {
//            // Show alert or error message indicating missing fields
//            return
//        }
//        
//        let newEntry = FuelEntry(date: Date(), carModel: carModelName, fuelQuantity: fuelQuantity, cost: cost)
//        fuelTracker.addFuelEntry(entry: newEntry, carModel: carModelName)
//        
//        self.odometerReading = ""
//        self.fuelQuantity = ""
//        self.cost = ""
//        self.fuelPrice = ""
//        self.carModelName = ""
//    }
//    
//    func deleteFuelEntry(at offsets: IndexSet) {
//        fuelTracker.fuelEntries.remove(atOffsets: offsets)
//    }
//}



struct FuelEntryRow: View {
    var entry: FuelEntry
    var mileageUnit: String // Add property for mileage unit

    var body: some View {
        VStack(alignment: .leading) {
            Text("Car Model: \(entry.carModel)")
            Text("Date: \(formattedDate(date: entry.date))")
            Text("Fuel Quantity: \(entry.fuelQuantity) liters")
            Text("Cost: $\(entry.cost)")
            Text("Mileage: \(calculateMileage(entry: entry)) \(mileageUnit)") // Display mileage with unit
        }
        .padding()
    }

    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func calculateMileage(entry: FuelEntry) -> Double {
        // Calculate mileage based on the selected unit
        if mileageUnit == "Miles per Gallon" {
            return entry.fuelQuantity / entry.cost
        } else {
            return entry.cost / entry.fuelQuantity
        }
    }
}



struct FuelExpensesView: View {
    @ObservedObject var fuelTracker: FuelTracker
    @ObservedObject var carViewModel = CarViewModel() // Add carViewModel
    
    var body: some View {
        VStack {
            List {
                ForEach(fuelTracker.fuelEntries) { entry in
                    FuelExpenseRow(entry: entry, carViewModel: carViewModel)
                }
                .onDelete(perform: deleteFuelEntry)
            }

            Text("Monthly Expenses: $\(calculateMonthlyExpenses())")
                .padding()
        }
        .navigationBarTitle("Fuel Expenses")
    }

    func deleteFuelEntry(at offsets: IndexSet) {
        fuelTracker.fuelEntries.remove(atOffsets: offsets)
    }

    func calculateMonthlyExpenses() -> Double {
        // Get the current calendar and date components
        let calendar = Calendar.current
        let currentDate = Date()

        // Get the year and month components of the current date
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)

        // Filter fuel entries by the current year and month
        let filteredEntries = fuelTracker.fuelEntries.filter { entry in
            let entryYear = calendar.component(.year, from: entry.date)
            let entryMonth = calendar.component(.month, from: entry.date)
            return entryYear == year && entryMonth == month
        }

        // Sum up the costs of filtered fuel entries
        let totalExpenses = filteredEntries.reduce(0) { $0 + $1.cost }
        return totalExpenses
    }
}

struct FuelExpenseRow: View {
    var entry: FuelEntry
    @ObservedObject var carViewModel: CarViewModel // Add carViewModel
   // var mileageUnit: String // Add mileageUnit property
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Car Model: \(entry.carModel)")
       //     Text("Mileage: \(calculateMileage(entry: entry)) \(mileageUnit)")
            Text("Date: \(formattedDate(date: entry.date))")
            Text("Fuel Quantity: \(entry.fuelQuantity) liters")
            Text("Cost: $\(entry.cost)")
        }
        .padding()
    }

    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func calculateMileage(entry: FuelEntry) -> String {
        // Find the car with the matching model
        if let car = carViewModel.cars.first(where: { $0.model == entry.carModel }) {
            // Calculate and return the mileage
            let mileage = Double(entry.fuelQuantity) / Double(entry.cost)
            return "\(mileage)"
        } else {
            return "N/A"
        }
    }
}




struct CarMaintenanceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



struct EditFuelEntryView: View {
    @ObservedObject var fuelTracker: FuelTracker
    var entry: FuelEntry
    @Binding var isPresented: Bool // Binding to control presentation
    @State private var date: Date
    @State private var fuelQuantity: String
    @State private var cost: String

    init(fuelTracker: FuelTracker, entry: FuelEntry, isPresented: Binding<Bool>) {
        self.fuelTracker = fuelTracker
        self.entry = entry
        self._isPresented = isPresented
        
        // Initialize states with the values of the selected entry
        _date = State(initialValue: entry.date)
        _fuelQuantity = State(initialValue: String(entry.fuelQuantity))
        _cost = State(initialValue: String(entry.cost))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Fuel Entry Details")) {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Fuel Quantity", text: $fuelQuantity)
                    .submitLabel(.done)
                    .keyboardType(.decimalPad)
                TextField("Cost", text: $cost)
                    .submitLabel(.done)
                    .keyboardType(.decimalPad)
            }
            
            Button(action: updateFuelEntry) {
                Text("Save Changes")
            }
           
        }
        .navigationBarTitle("Edit Fuel Entry")
    }
    
    func updateFuelEntry() {
        guard let fuelQuantity = Double(fuelQuantity),
              let cost = Double(cost) else { return }
        
        // Update the properties of the selected entry
        if let index = fuelTracker.fuelEntries.firstIndex(where: { $0.id == entry.id }) {
            fuelTracker.fuelEntries[index].date = date
            fuelTracker.fuelEntries[index].fuelQuantity = fuelQuantity
            fuelTracker.fuelEntries[index].cost = cost
        }
        // Dismiss the sheet upon saving changes
        isPresented = false
    }
}


