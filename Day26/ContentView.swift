//
//  ContentView.swift
//  Day26
//
//  Created by Anu Mittal on 16/02/21.
//

import SwiftUI

struct ContentView: View {
  @State private var sleepAmount = 8.0
  @State private var wakeUp = defaultWakeUpTime
  @State private var coffeeAmount = 1
  @State private var sleepTime = ""
  
  
  @State private var alertTitle = ""
  @State private var alertMessage = ""
  @State private var showingAlert = false
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("When do you want to wake up?")){
          DatePicker("Please enter a date", selection: $wakeUp, displayedComponents: .hourAndMinute)
            .labelsHidden()
            .datePickerStyle(WheelDatePickerStyle())
            .onChange(of: wakeUp, perform: { value in
              calculateBedTime()
            })
        }
        
        Section(header: Text("Desired amount of sleep")) {
          Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
            Text("\(sleepAmount, specifier:"%g") hours")
          }
        }
        .onReceive([self.$sleepAmount].publisher.first(), perform: { _ in
          calculateBedTime()
        })
        
        Section {
          Picker("Daily coffee intake", selection: $coffeeAmount) {
            ForEach(0 ..< 20) { cup in
              if cup <= 1 {
                Text("\(cup) cup")
              } else {
                Text("\(cup) cups")
              }
            }
          }
          .onChange(of: coffeeAmount, perform: { value in
            calculateBedTime()
          })
        }
        
        Section(header: Text("Sleep time should be")) {
          Text("\(sleepTime)")
            .font(.largeTitle)
            .foregroundColor(.blue)
        }
      }
      .navigationBarTitle("BetterRest")
    }
  }
  
  static var defaultWakeUpTime: Date {
    var components = DateComponents()
    components.hour = 7
    components.minute = 0
    return Calendar.current.date(from: components) ?? Date()
  }
  
   func calculateBedTime() {
    let model = SleepCalculator()
    let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
    let hour = (components.hour ?? 0) * 60 * 60
    let minute = (components.minute ?? 0) * 60
    
    do {
      let prediction = try model.prediction(
        wake: Double(hour + minute),
        estimatedSleep: sleepAmount,
        coffee: Double(coffeeAmount))
      let bedTime = wakeUp - prediction.actualSleep
      
      let formatter = DateFormatter()
      formatter.timeStyle = .short
      sleepTime = formatter.string(from: bedTime)
      
      /*
       *  Day 27 Part 2
       *  alertMessage = formatter.string(from: sleepTime)
       *  alertTitle = "Your ideal bedtime is…"
       */
    } catch {
      print("Error: Sorry, there was a problem calculating the bedtime.")
      /*
       *  Day 27 Part 2
       *  alertTitle = "Error"
       *  alertMessage = "Sorry, there was a problem calculating your bedtime."
       */
    }
    //  showingAlert = true
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
