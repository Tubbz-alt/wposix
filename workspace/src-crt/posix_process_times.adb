
--  $Id$

with Win32.Winbase;
with POSIX_Win32;

package body POSIX_Process_Times is

   Result : Win32.BOOL;

   function Filetime_To_Tick (Filetime : in Win32.Winbase.Filetime)
                              return Tick_Count
   is
      use type Win32.ULONG;
      Hundred_Nano_To_Tick : constant := 1E7 / Ticks_Per_Second;
      Total_Tick : Long_Long_Integer;

      function Shift_Left (Value  : Win32.DWORD;
                           Amount : Natural)
                           return    Win32.DWORD;
      pragma Convention (Intrinsic, Shift_Left);
      pragma Import (Intrinsic, Shift_Left);

   begin
      Total_Tick := Long_Long_Integer
        (Shift_Left (Filetime.DwHighDateTime, 32) +
         Filetime.DwLowDateTime);
      return Tick_Count (Total_Tick / Hundred_Nano_To_Tick);
   end Filetime_To_Tick;

   function Elapsed_Real_Time
     return Tick_Count is
   begin
      return Elapsed_Real_Time_Of (Get_Process_Times);
   end Elapsed_Real_Time;

                    -----------------------------------

   function Get_Process_Times
     return Process_Times
   is
      PT : Process_Times;
      Creation_Time, Exit_Time : aliased Win32.Winbase.Filetime;
      Kernel_Time, User_Time   : aliased Win32.Winbase.Filetime;
   begin
      Result := Win32.Winbase.GetProcessTimes
        (Win32.Winbase.GetCurrentProcess,
         Creation_Time'Unchecked_Access,
         Exit_Time'Unchecked_Access,
         Kernel_Time'Unchecked_Access,
         User_Time'Unchecked_Access);
      POSIX_Win32.Check_Result (Result, "Get_Process_Times");

      PT := (User_Time   => Filetime_To_Tick (User_Time),
             System_Time => Filetime_To_Tick (Kernel_Time),
             Children_User_Time |
             Children_System_Time => 0);
      return PT;
   end Get_Process_Times;

                    -----------------------------------

   function Elapsed_Real_Time_Of (Times : Process_Times)
                                  return Tick_Count is
   begin
      return Times.User_Time + Times.System_Time +
        Times.Children_User_Time + Times.Children_System_Time;
   end Elapsed_Real_Time_Of;

                    -----------------------------------

   function User_CPU_Time_Of (Times : Process_Times)
                              return Tick_Count is
   begin
      return Times.User_Time;
   end User_CPU_Time_Of;

                    -----------------------------------

   function System_CPU_Time_Of (Times : Process_Times)
                                return Tick_Count is
   begin
      return Times.System_Time;
   end System_CPU_Time_Of;

                    -----------------------------------

   function Descendants_User_CPU_Time_Of (Times : Process_Times)
                                          return Tick_Count is
   begin
      return Times.Children_User_Time;
   end Descendants_User_CPU_Time_Of;

                    -----------------------------------

   function Descendants_System_CPU_Time_Of (Times : Process_Times)
                                            return Tick_Count is
   begin
      return Times.Children_System_Time;
   end Descendants_System_CPU_Time_Of;

end POSIX_Process_Times;
