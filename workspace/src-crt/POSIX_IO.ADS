
--  $Id$

with Ada.Unchecked_Conversion;

with POSIX;
with POSIX_Permissions;

with Win32;
with Win32.Crt.Fcntl;

package POSIX_IO is


   --  Common type declarations

   type File_Descriptor is range 0 .. POSIX.Open_Files_Maxima'Last - 1;

   Standard_Input  : constant File_Descriptor := 0;
   Standard_Output : constant File_Descriptor := 1;
   Standard_Error  : constant File_Descriptor := 2;

   type IO_Offset is new Long_Integer;

   --  Files Modes and Options

   type File_Mode is (Read_Only, Write_Only, Read_Write);

   type Open_Option_Set is new POSIX.Option_Set;
   --  Empty_Set, "+" and "-" are derived operations

   Non_Blocking               : constant Open_Option_Set; --  not implemented

   Append                     : constant Open_Option_Set;

   Truncate                   : constant Open_Option_Set;

   Exclusive                  : constant Open_Option_Set;

   Not_Controlling_Terminal   : constant Open_Option_Set; --  not implemented



   --  Operations to open or close file descriptors

   function Open
     (Name           : POSIX.Pathname;
      Mode           : File_Mode;
      Options        : Open_Option_Set := Empty_Set;
      Masked_Signals : POSIX.Signal_Masking := POSIX.RTS_Signals)
      return File_Descriptor;

   function Open_Or_Create
     (Name           : POSIX.Pathname;
      Mode           : File_Mode;
      Permissions    : POSIX_Permissions.Permission_Set;
      Options        : Open_Option_Set := Empty_Set;
      Masked_Signals : POSIX.Signal_Masking := POSIX.RTS_Signals)
      return File_Descriptor;

   function Is_Open (File : File_Descriptor)
                     return Boolean;

   procedure Close
     (File           : in File_Descriptor;
      Masked_Signals : in POSIX.Signal_Masking := POSIX.RTS_Signals);


   function Duplicate
     (File   : File_Descriptor;
      Target : File_Descriptor := 0)
      return File_Descriptor;

   function Duplicate_And_Close
     (File           : File_Descriptor;
      Target         : File_Descriptor := 0;
      Masked_Signals : POSIX.Signal_Masking := POSIX.RTS_Signals)
      return File_Descriptor;

   procedure Create_Pipe
     (Read_End  : out File_Descriptor;
      Write_End : out File_Descriptor);



   --  File Input/Output operations

   subtype IO_Buffer is POSIX.POSIX_String;

   procedure Read
     (File           : in     File_Descriptor;
      Buffer         :    out IO_Buffer;
      Last           :    out POSIX.IO_Count;
      Masked_Signals : in     POSIX.Signal_Masking := POSIX.RTS_Signals);

   procedure Write
     (File           : in     File_Descriptor;
      Buffer         : in     IO_Buffer;
      Last           :    out POSIX.IO_Count;
      Masked_Signals : in     POSIX.Signal_Masking := POSIX.RTS_Signals);

   generic
      type T is private;
   procedure Generic_Read
     (File           : in     File_Descriptor;
      Item           :    out T;
      Masked_Signals : in     POSIX.Signal_Masking := POSIX.RTS_Signals);

   generic
      type T is private;
   procedure Generic_Write
     (File           : in     File_Descriptor;
      Item           : in     T;
      Masked_Signals : in     POSIX.Signal_Masking := POSIX.RTS_Signals);




   --  File position operations

   type Position is (From_Beginning, From_Current_Position, From_End_Of_File);

   procedure Seek
     (File           : in     File_Descriptor;
      Offset         : in     IO_Offset;
      Result         :    out IO_Offset;
      Starting_Point : in     Position := From_Beginning);

   function File_Size (File : File_Descriptor)
                       return POSIX.IO_Count;

   function File_Position (File : File_Descriptor)
                           return POSIX.IO_Count;



   --  Terminal operations

   function Is_A_Terminal (File : File_Descriptor)
                           return Boolean;

   function Get_Terminal_Name (File : File_Descriptor)
                               return POSIX.Pathname;



   --  File Control operations

   procedure Get_File_Control
     (File       : in     File_Descriptor;
      Mode       :    out File_Mode;
      Options    :    out Open_Option_Set);

   procedure Set_File_Control
     (File       : in     File_Descriptor;
      Options    : in     Open_Option_Set);

   function Get_Close_On_Exec (File : File_Descriptor)
                               return Boolean;

   procedure Set_Close_On_Exec
     (File : in     File_Descriptor;
      To   : in     Boolean := True);

private

   function UINT_To_Open_Option_Set is new
     Ada.Unchecked_Conversion (Win32.UINT, Open_Option_Set);

   Dummy : constant := 0;

   Non_Blocking             : constant Open_Option_Set :=
     UINT_To_Open_Option_Set (Dummy);

   Append                   : constant Open_Option_Set :=
     UINT_To_Open_Option_Set (Win32.Crt.Fcntl.O_APPEND);

   Truncate                 : constant Open_Option_Set :=
     UINT_To_Open_Option_Set (Win32.Crt.Fcntl.O_TRUNC);

   Exclusive                : constant Open_Option_Set :=
     UINT_To_Open_Option_Set (Win32.Crt.Fcntl.O_EXCL);

   Not_Controlling_Terminal : constant Open_Option_Set :=
     UINT_To_Open_Option_Set (Dummy);

end POSIX_IO;
