
--  $Id$
--  Author : Pascal Obry
--  p.obry@wanadoo.fr

with POSIX.Permissions;
with POSIX.Process_Identification;
with POSIX.IO;
with POSIX.Calendar;

with Win32.Winbase;

package POSIX.File_Status is

   type Status is private;


   --  Operations to Obtain File Status

   function Get_File_Status (Pathname : POSIX.Pathname)
                             return Status;

   function Get_File_Status (File     : POSIX.IO.File_Descriptor)
                             return Status;


   --  Operations to get information from Status

   type File_ID is private;

   type Device_ID is private;

   subtype Links is Natural range 0 .. POSIX.Link_Limit_Maxima'Last;

   function Permission_Set_Of (File_Status : Status)
                               return POSIX.Permissions.Permission_Set;

   function File_ID_Of (File_Status : Status)
                        return File_ID;

   function Device_ID_Of (File_Status : Status)
                          return Device_ID;

   function Link_Count_Of (File_Status : Status)
                           return Links;

   function Owner_Of (File_Status : Status)
                      return POSIX.Process_Identification.User_ID;

   function Group_Of (File_Status : Status)
                      return POSIX.Process_Identification.Group_ID;

   function Size_Of (File_Status : Status)
                     return POSIX.IO_Count;

   function Last_Access_Time_Of (File_Status : Status)
                                 return POSIX.Calendar.POSIX_Time;

   function Last_Modification_Time_Of (File_Status : Status)
                                       return POSIX.Calendar.POSIX_Time;

   function Last_Status_Change_Time_Of (File_Status : Status)
                                        return POSIX.Calendar.POSIX_Time;

   function Is_Directory (File_Status : Status)
                          return Boolean;

   function Is_Character_Special_File (File_Status : Status)
                                       return Boolean;

   function Is_Block_Special_File (File_Status : Status)
                                   return Boolean;

   function Is_Regular_File (File_Status : Status)
                             return Boolean;

   function Is_FIFO (File_Status : Status)
                     return Boolean;


private

   type Status is
      record
         Is_Executable    : Boolean     := False;
         File_Attributes  : Win32.DWORD := 0;
         Creation_Time    : Win32.Winbase.FILETIME;
         Last_Access_Time : Win32.Winbase.FILETIME;
         Last_Write_Time  : Win32.Winbase.FILETIME;
         File_Size_Low    : Win32.DWORD := 0;
         File_Size_High   : Win32.DWORD := 0;
         File_Index_Low   : Win32.DWORD := 0;
         File_Index_High  : Win32.DWORD := 0;
         File_Links       : Win32.DWORD := 0;
         File_Type        : Win32.DWORD := Win32.Winbase.FILE_TYPE_UNKNOWN;
      end record;

   type File_ID is
      record
         Low, High : Win32.DWORD;
      end record;

   type Device_ID is new Integer;

end POSIX.File_Status;