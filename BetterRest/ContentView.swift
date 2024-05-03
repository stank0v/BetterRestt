//
//  ContentView.swift
//  BetterRest
//
//  Created by Hristo Stankov on 3.05.24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    var body: some View {
        
            NavigationStack {
                VStack {
                    //Spacer()
                    HStack{
                        Text("When do you want to wake up?")
                            .font(.headline)
                        DatePicker("", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            //.labelsHidden()
                    }.padding(.vertical)
                    VStack(alignment:.leading){
                        Text("Desired amount of sleep")
                            .font(.headline)
                        
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    HStack{
                 //   VStack(alignment:.leading){
                        Text("Daily intake of coffee")
                            .font(.headline)
                        Spacer()
                        //Stepper("^[\(coffeeAmount) cup](inflect:true)", value: $coffeeAmount, in: 1...20)
                        Picker("^[\(coffeeAmount) cup](inflect:true)", selection: $coffeeAmount) {
                            ForEach(1..<20) {cup in
                                Text("^[\(cup-1) cup](inflect:true)")
                            }
                        }.pickerStyle(.menu)
                    }.padding(.vertical)
                    
                    Text("Your ideal bedtime is: ")
                        .font(.title)
                        .padding(.bottom,20)
                    Text(alertMessage)
                        .font(.largeTitle)
                        .foregroundStyle(.primary)
                    Spacer()
                    Button("Calculate", action: calculateBedtime)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        
                    
                } .padding(.horizontal,30)
                    .padding(.top,50)
               
                .navigationTitle("BetterRest")
                
                    
                
               
            }
   
        }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating yyour bedtime"
        }
        showingAlert = true
    }
    
}

#Preview {
    ContentView()
}
