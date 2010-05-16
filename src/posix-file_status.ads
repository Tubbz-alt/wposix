------------------------------------------------------------------------------
--                                  wPOSIX                                  --
--                                                                          --
--                     Copyright (C) 2008-2010, AdaCore                     --
--                                                                          --
--  This library is free software; you can redistribute it and/or modify    --
--  it under the terms of the GNU General Public License as published by    --
--  the Free Software Foundation; either version 2 of the License, or (at   --
--  your option) any later version.                                         --
--                                                                          --
--  This library is distributed in the hope that it will be useful, but     --
--  WITHOUT ANY WARRANTY; without even the implied warranty of              --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       --
--  General Public License for more details.                                --
--                                                                          --
--  You should have received a copy of the GNU General Public License       --
--  along with this library; if not, write to the Free Software Foundation, --
--  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.          --
--                                                                          --
--  As a special exception, if other files instantiate generics from this   --
--  unit, or you link this unit with other files to produce an executable,  --
--  this  unit  does not  by itself cause  the resulting executable to be   --
--  covered by the GNU General Public License. This exception does not      --
--  however invalidate any other reasons why the executable file  might be  --
--  covered by the  GNU Public License.                                     --
------------------------------------------------------------------------------

with POSIX.Permissions;
with POSIX.Process_Identification;
with POSIX.IO;
with POSIX.Calendar;

private with Ada.Finalization;
private with Ada.Strings.Unbounded;
private with Win32.Winbase;
private with Win32.Winnt;

package POSIX.File_Status is

   type Status is private;

   --  Operations to Obtain File Status

   function Get_File_Status (Pathname : POSIX.Pathname) return Status;

   function Get_File_Status (File : POSIX.IO.File_Descriptor) return Status;

   --  Operations to get information from Status

   type File_ID is private;

   type Device_ID is private;

   subtype Links is Natural range 0 .. POSIX.Link_Limit_Maxima'Last;

   function Permission_Set_Of
     (File_Status : Status) return POSIX.Permissions.Permission_Set;

   function File_ID_Of
     (File_Status : Status) return File_ID;

   function Device_ID_Of
     (File_Status : Status) return Device_ID;

   function Link_Count_Of
     (File_Status : Status) return Links;

   function Owner_Of
     (File_Status : Status) return POSIX.Process_Identification.User_ID;

   function Group_Of
     (File_Status : Status) return POSIX.Process_Identification.Group_ID;

   function Size_Of
     (File_Status : Status) return POSIX.IO_Count;

   function Last_Access_Time_Of
     (File_Status : Status) return POSIX.Calendar.POSIX_Time;

   function Last_Modification_Time_Of
     (File_Status : Status) return POSIX.Calendar.POSIX_Time;

   function Last_Status_Change_Time_Of
     (File_Status : Status) return POSIX.Calendar.POSIX_Time;

   function Is_Directory (File_Status : Status) return Boolean;

   function Is_Character_Special_File
     (File_Status : Status) return Boolean;

   function Is_Block_Special_File
     (File_Status : Status) return Boolean;

   function Is_Regular_File (File_Status : Status) return Boolean;

   function Is_FIFO (File_Status : Status) return Boolean;

private

   use Ada;
   use Ada.Strings.Unbounded;

   type Shared_Data is record
      Owner, Group : aliased Win32.Winnt.PSID;
      DACL         : aliased Win32.Winnt.PACL;
      Ref_Count    : Natural;
   end record;

   type Shared_Data_Access is access all Shared_Data;

   type Status is new Finalization.Controlled with record
      File             : POSIX.IO.File_Descriptor := 0;
      File_Name        : Unbounded_String;
      Is_Executable    : Boolean     := False;
      File_Attributes  : Win32.DWORD := 0;
      Creation_Time    : Win32.Winbase.FILETIME;
      Last_Access_Time : Win32.Winbase.FILETIME;
      Last_Write_Time  : Win32.Winbase.FILETIME;
      File_Size_Low    : Win32.DWORD := 0;
      File_Size_High   : Win32.DWORD := 0;
      File_Links       : Win32.DWORD := 0;
      File_Type        : Win32.DWORD := Win32.Winbase.FILE_TYPE_UNKNOWN;
      Data             : Shared_Data_Access;
   end record;

   overriding procedure Initialize (File_Status : in out Status);
   overriding procedure Finalize (File_Status : in out Status);
   overriding procedure Adjust (File_Status : in out Status);

   type File_ID is record
      Low, High : Win32.DWORD;
   end record;

   type Device_ID is new Integer;

end POSIX.File_Status;
